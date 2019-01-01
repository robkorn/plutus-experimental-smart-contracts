-- This is a "Customizable Wallet" which allows you to set a name and choose during which block heights withdrawls are allowed.

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import qualified Language.PlutusTx.Builtins   as Builtins
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract


data WalletInfo = WalletInfo { walletName :: ByteString
                             , allowedWithdrawHeights :: [Int]
                             }

PlutusTx.makeLift ''WalletInfo

currentWalletInfo :: WalletInfo
currentWalletInfo = WalletInfo "My Customizable Wallet" [5, 9, 25]


custWalletValidator :: WalletInfo -> ValidatorScript
custWalletValidator wi = ValidatorScript whole
  where whole = Ledger.applyScript main $ Ledger.lifted wi
        main = Ledger.fromCompiledCode $$(PlutusTx.compile
               [||
               \(wi :: WalletInfo) (rs :: ()) (ds :: ()) (p :: PendingTx') ->
                 let PendingTx _ _ _ _ height _ _ = p
                     WalletInfo name allowedHeights = wi

                     getIntFromHeight :: Height -> Int
                     getIntFromHeight (Height i) = i

                     isWithdrawAllowed :: [Int] -> Bool
                     isWithdrawAllowed [] = False
                     isWithdrawAllowed (x : xs) = if x == iHeight then True else isWithdrawAllowed xs
                       where iHeight = getIntFromHeight height
                 in
                  if isWithdrawAllowed allowedHeights
                  then ()
                  else $$(P.error) ( $$(P.traceH) "Sorry, your withdrawl cannot be processed at the current time. Please wait until an allowed block height and try again." ())
                ||])


walletAddress :: Address'
walletAddress = Ledger.scriptAddress $ custWalletValidator currentWalletInfo


deposit :: Value -> MockWallet ()
deposit val = payToScript_ walletAddress val unitData

withdraw :: MockWallet ()
withdraw = collectFromScript (custWalletValidator currentWalletInfo) unitRedeemer

$(mkFunction 'deposit)
$(mkFunction 'withdraw)
