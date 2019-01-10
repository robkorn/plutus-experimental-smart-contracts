-- Currently unfinished due to the buggy user experience of having broken error messages in Plutus Playground. The complexity of the contract taxes one's ability to simply guess what error one has made, so it is put on hold for now.

-- Smart contract where people purchase tickets and provide a hashed block height. If they have the majority of stake put into the SC behind their hashed block height, then withdraws will be allowed on that block height. Includes a backupHeight where if all players failed to withdraw on the won block height, then any block after height backupHeight will allow withdrawls by anyone.
{-# LANGUAGE OverloadedStrings #-}

import qualified Language.PlutusTx            as PlutusTx
import qualified Language.PlutusTx.Prelude    as P
import qualified Language.PlutusTx.Builtins   as Builtins
import           Ledger
import           Ledger.Validation
import           Wallet
import           Playground.Contract

data GameInfo = GameInfo { backupHeight :: Height }

PlutusTx.makeLift ''GameInfo

currentGameInfo :: GameInfo
currentGameInfo = GameInfo 500


gameValidator :: GameInfo -> ValidatorScript
gameValidator gi = ValidatorScript whole
  where whole = applyScript main $ lifted gi
        main  = fromCompiledCode $ $$(PlutusTx.compile
                [||
                 \GameInfo{..} (rs :: ()) (ticketHeight :: Height) (p :: PendingTx') ->
                   let PendingTx _ outs _ _ currentHeight _ _ = p

                       -- The derived Ord instance for Height causes an error on compile for some reason (can't see error with current Plutus Playground bugs) and Haskell doesn't have instance overriding as far as I know, so creating a manual functon to pattern match the Int out.
                       ghi :: Height -> Int
                       ghi (Height i) = i
                       pastBackupHeight = ghi currentHeight > ghi backupHeight

                       -- Creating the hash of the currentHeight to compare with the previous deposited ticket hashes
                       currentHeightHashed :: DataScriptHash
                       currentHeightHashed = plcDataScriptHash $ DataScript $ lifted currentHeight
                       getDataScriptHash :: PendingTxOut -> DataScriptHash
                       getDataScriptHash (PendingTxOut _ (Just (valdHash, dsHash)) _) = dsHash
                       getDataScriptHash _ = DataScriptHash ""

                       dshList :: [DataScriptHash]
                       dshList = $$(P.map) getDataScriptHash outs

                       -- Temporarily using partial head to test if hashing equality works
                       head (x : xs) = x

                   in
                     -- if pastBackupHeight
                     if $$(eqDataScript) (head dshList) currentHeightHashed
                     then ()
                     else $$(P.error) ($$(P.traceH) "This is not the current winning height!" ())
                ||])

gameAddress :: Address'
gameAddress = scriptAddress $ gameValidator currentGameInfo

watchGame :: MockWallet ()
watchGame = startWatching gameAddress


buyTicket :: Height -> MockWallet ()
buyTicket h = let ds = DataScript $ lifted h
              in payToScript_ gameAddress 1 ds

withdrawFromGame :: MockWallet ()
withdrawFromGame = collectFromScript (gameValidator currentGameInfo) unitRedeemer


$(mkFunction 'watchGame)
$(mkFunction 'buyTicket)
$(mkFunction 'withdrawFromGame)
