public with sharing class LeadDuplicateHandler {
    @TestVisible
    public static void checkDuplicatedLeads(List<Lead> newLeads){
        Set<String> emails = new Set<String>();
        Set<String> ownIds = new Set<String>();
        //Bring all called Leads
        for(Lead l : newLeads){
            if(l.Id != null){
                ownIds.add(l.id);
            }
            if(String.isNotBlank(l.Email)){
                emails.add(normalize(l.Email));
            }
        }
        if(emails.isEmpty()){
            return;
        }

        //Bulk Soql query
        Set<String> existing = new Set<String>();
        for (Lead L : [SELECT Email FROM Lead WHERE Email in :emails AND Id NOT IN :ownIds]){
            existing.add(normalize(L.Email));
        }

        //Determine the concerned Leads
        Set<String> marked = new Set<String>();
        for(Lead l: newLeads){
            if(String.isBlank(l.Email)){
                continue;}
                String key = normalize(l.Email);
                if(existing.contains(key) || !marked.add(key)){
    marked.add(key);
    l.Email.addError('Email already exists');
}
            }
        }
        private static String normalize(String email) {
    return email.trim().toLowerCase();
}    
    }
