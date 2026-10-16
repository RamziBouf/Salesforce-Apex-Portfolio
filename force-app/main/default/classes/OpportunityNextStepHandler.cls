public with sharing class OpportunityNextStepHandler {
    public static void opportunityChangeHandler(List<Opportunity> newOpps){
        
        for(Opportunity opp : newOpps){
            if(opp.StageName == 'Negotiation/Review' && String.isBlank(opp.NextStep)){
                opp.addError('The next Step is missing!');}
        }

    }
}