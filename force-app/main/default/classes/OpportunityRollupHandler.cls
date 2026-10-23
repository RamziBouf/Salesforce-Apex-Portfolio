public with sharing class OpportunityRollupHandler {
  public static void HandelAfterContext(List<Opportunity> newList, Map<Id, Opportunity> oldMap, System.TriggerOperation context)
  {
    Set<Id>accountsToUpdate = new Set<Id>();
    if(context == System.TriggerOperation.AFTER_INSERT || context == System.TriggerOperation.AFTER_UNDELETE)
    {
      for(Opportunity opp : newList){
        if(opp.AccountId != null && opp.StageName== 'Closed Won'){
          accountsToUpdate.add(opp.AccountId);
        }
      }

  }else if(context == System.TriggerOperation.AFTER_DELETE){
    for(Opportunity opp : oldMap.values()){
      if(opp.AccountId != null && opp.StageName == 'Closed Won'){
      accountsToUpdate.add(opp.AccountId);
    }
    }
  }
  else if(context == System.TriggerOperation.AFTER_UPDATE){
    for(Opportunity opp : newList){
      Opportunity oldOpp = oldMap.get(opp.Id);
      Boolean stageChanged = opp.StageName != oldOpp.StageName;
      Boolean amountChanged = opp.Amount != oldOpp.Amount;
      Boolean accountChanged = opp.AccountId != oldOpp.AccountId;
      if(amountChanged || stageChanged || accountChanged){
        if (opp.AccountId != null) {
          accountsToUpdate.add(opp.AccountId);
        }
        if (oldOpp.AccountId != null) {
          accountsToUpdate.add(oldOpp.AccountId);
        }
      }}
    }
    if(accountsToUpdate.isEmpty()) return;
    Map<Id, Decimal> accountsToTotalWon = new Map<Id, Decimal>();

    for(Id accId : accountsToUpdate){
      accountsToTotalWon.put(accId, 0);
    }

    for(AggregateResult ar : [
      SELECT AccountId accId, SUM(Amount) total
      FROM Opportunity
      WHERE AccountId IN :accountsToUpdate AND StageName = 'Closed Won'
      WITH USER_MODE
      GROUP BY AccountId
    ]) {
      Id accId = (Id) ar.get('accId');
      Decimal total = (Decimal) ar.get('total');
      accountsToTotalWon.put(accId, total != null  ? total : 0);
  }
  List<Account> accountsToBeUpdated = new list<Account>();
  for (Id accId : accountsToTotalWon.keySet()){
    accountsToBeUpdated.add(new Account(Id = accId, Total_Won_Amount__c =accountsToTotalWon.get(accId)));
  }

  if(!accountsToBeUpdated.isEmpty()){
    update as User accountsToBeUpdated;
  }
}
}