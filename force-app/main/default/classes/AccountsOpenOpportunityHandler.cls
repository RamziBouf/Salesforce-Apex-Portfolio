public with sharing class AccountsOpenOpportunityHandler {
    @TestVisible
    public static void handleOpenOpportunities(List<Account> accounts){
        Set<Account> accounts_with_open_opp= new Set<Account>();
        for(Account acc : [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE IsClosed = false)]){
           accounts_with_open_opp.add(acc);
        }

        for(Account acc : accounts){
        if(accounts_with_open_opp.contains(acc)){
            acc.Name.addError('This account has at least one open opportunity.');
        }}
    }
}
