-- To finish this SC off we implement a check that the winning number supplied and the guessed number are both natural numbers (aka not negative) and throw an error otherwise.

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

natCheck :: Int -> MockWallet ()
natCheck num = if num < 0 then throwOtherError "There must be a positive number of jellybeans in the jar." else pure ()

lockNumber :: Int -> Value -> MockWallet ()
lockNumber num prize = do
  natCheck num
  let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
  payToScript_ scAddress prize $ DataScript $ Ledger.lifted hashedNum
  register closeGameTrigger (closeGameHandler hashedNum)

guessNumber :: Int -> MockWallet ()
guessNumber num = do
  natCheck num
  let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
  collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted hashedNum

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
