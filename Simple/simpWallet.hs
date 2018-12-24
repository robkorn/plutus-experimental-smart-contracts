-- This is an empty SC with the most basic setup needed to get started.

module SimpWallet where

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract


walletValidator :: ValidatorScript
walletValidator = Ledger.emptyValidator

scAddress :: Address'
scAddress = Ledger.scriptAddress walletValidator

deposit :: Value -> MockWallet ()
deposit val = payToScript_ scAddress val Ledger.unitData

withdraw :: MockWallet ()
withdraw = collectFromScript walletValidator Ledger.unitRedeemer

registerWallet :: MockWallet ()
registerWallet = startWatching scAddress

$(mkFunction 'registerWallet)
$(mkFunction 'deposit)
$(mkFunction 'withdraw)
