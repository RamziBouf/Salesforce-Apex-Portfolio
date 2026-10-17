trigger autoRateLeads on Lead (before insert, before update) {
    autoRateLeadsHandler.autoRateLeads(Trigger.new);
}