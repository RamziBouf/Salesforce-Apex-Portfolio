trigger AccountsOpenOpportunity on Account (before delete) {
    AccountsOpenOpportunityHandler.handleOpenOpportunities(Trigger.old);
}