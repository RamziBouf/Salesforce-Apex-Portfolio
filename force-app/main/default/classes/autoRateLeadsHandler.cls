public with sharing class autoRateLeadsHandler {

    private static final Decimal threshold = 1000000;
    public static void autoRateLeads(List<Lead> newLeads){
        for(Lead l : newLeads){
            Boolean HighRevenue = l.AnnualRevenue != null && l.AnnualRevenue > threshold;
            Boolean isReferral = l.LeadSource == 'Partner Referral';
            if(HighRevenue || isReferral){
                l.Rating = 'Hot';
            }
        }
    }
}