-- SimpWallet is an empty SC allowing anyone to deposit and withdraw all funds from the SC (assuming their wallet is registered to track the SC before others deposit)
module SimpWallet where

import qualified Language.PlutusTx            as PlutusTx
import           Ledger
import           Wallet
import           Playground.Contract


walletValidator :: ValidatorScript
walletValidator = ValidatorScript $ Ledger.fromCompiledCode
                  $$(PlutusTx.compile
                     [||
                     -- Due to what appears to be a bug we cannot use emptyValidator currently. The compiler seems to need the input types explicitly defined even if not used.
                      \(r :: ()) (d :: ()) (v :: ()) -> ()
                      ||])

scAddress :: Address'
scAddress = Ledger.scriptAddress walletValidator

deposit :: Value -> MockWallet ()
deposit val = payToScript_ scAddress val Ledger.unitData

withdraw :: MockWallet ()
withdraw = collectFromScript walletValidator Ledger.unitRedeemer

watchSCWallet :: MockWallet ()
watchSCWallet = startWatching scAddress

$(mkFunction 'watchSCWallet)
$(mkFunction 'deposit)
$(mkFunction 'withdraw)
