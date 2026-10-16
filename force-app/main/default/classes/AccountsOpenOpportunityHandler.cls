public with sharing class AccountsOpenOpportunityHandler {
    
    public static void handleOpenOpportunities(List<Account> accounts){
        //maping all the deleted accounts
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        Set<Id> accounts_with_open_opp= new Set<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT AccountId FROM Opportunity WHERE IsClosed = false)]){
           accounts_with_open_opp.add(acc.Id);
        }

        for(Account acc : accounts){
        if(accounts_with_open_opp.contains(acc.Id)){
            acc.Name.addError('This account has at least one open opportunity.');
        }}
    }
}
