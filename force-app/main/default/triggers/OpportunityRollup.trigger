trigger OpportunityRollup on Opportunity (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter){
        OpportunityRollupHandler.HandelAfterContext(Trigger.new, Trigger.oldMap, Trigger.operationType);
    }
}