
-- We now create a trigger and handler which gets registered in our lockNumber function. This tells the wallet to call the handler whenever the trigger is met. In our case this means closing the game and withdrawing funds if the block height gets to 10 and the player has not sucessfullly guessed the winning number.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import qualified Language.PlutusTx.Builtins   as Builtins
import qualified Data.ByteString.Lazy.Char8   as BSLC
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract



jbValidator :: ValidatorScript
jbValidator = ValidatorScript $ Ledger.fromCompiledCode $$(PlutusTx.compile
  [||
   \(guessedNum :: ByteString) (winningNum :: ByteString) (p :: PendingTx') ->
    if ($$(P.equalsByteString) guessedNum winningNum)
    then ()
    else $$(P.error) ($$(P.traceH) "That is not correct!" ())
   ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress jbValidator

lockNumber :: Int -> Value -> MockWallet ()
lockNumber num prize = do
  let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
  payToScript_ scAddress prize $ DataScript $ Ledger.lifted hashedNum
  register closeGameTrigger (closeGameHandler hashedNum)

guessNumber :: Int -> MockWallet ()
guessNumber num = let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
                  in collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted hashedNum

watchSCAddress :: MockWallet ()
watchSCAddress = startWatching scAddress

closeGameTrigger :: EventTrigger
closeGameTrigger = andT
  (fundsAtAddressT scAddress $ GEQ 1)
  (blockHeightT (Interval (Height 10) (Height 11)))

closeGameHandler :: ByteString -> EventHandler MockWallet
closeGameHandler hashedNum = EventHandler (\_ -> do
    logMsg "Player Failed To Guess The Answer In Time."
    logMsg "Ending game and withdrawing money from SC."
    collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted hashedNum)

$(mkFunction 'lockNumber)
$(mkFunction 'guessNumber)
$(mkFunction 'watchSCAddress)
