trigger OpportunityNextStepTrigger on Opportunity (before update) {
    OpportunityNextStepHandler.opportunityChangeHandler(Trigger.new);
}