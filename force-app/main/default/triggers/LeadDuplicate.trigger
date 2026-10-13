trigger LeadDuplicate on Lead (before insert, before update) {
    LeadDuplicateHandler.checkDuplicatedLeads(Trigger.new);
}