
-- In this file we now hash the guessedNum/winningNum before submitting them to the SC, then check for equality between the two ByteStrings. It is possible to do the hashing on-chain for the guessedNum, but this should incur a higher gas cost, so it's better to do it offchain in the wallet.

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
lockNumber num prize = let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
                       in payToScript_ scAddress prize $ DataScript $ Ledger.lifted hashedNum

guessNumber :: Int -> MockWallet ()
guessNumber num = let hashedNum = plcSHA2_256 $ BSLC.pack $ show num
                  in collectFromScript jbValidator $ RedeemerScript $ Ledger.lifted hashedNum

watchSCAddress :: MockWallet ()
watchSCAddress = startWatching scAddress

$(mkFunction 'lockNumber)
$(mkFunction 'guessNumber)
$(mkFunction 'watchSCAddress)
