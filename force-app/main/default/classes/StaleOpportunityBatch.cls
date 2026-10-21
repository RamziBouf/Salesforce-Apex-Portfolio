public with sharing class StaleOpportunityBatch  implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
   private final Integer daysOverdue;
   private Integer succeeded;
   private Integer failed;

   public StaleOpportunityBatch(){
    this(90);
   }

   public StaleOpportunityBatch(Integer daysOverdue){
    this.daysOverdue = daysOverdue;
   }

   //bring the records to be processed
   public Database.QueryLocator start(Database.BatchableContext context){
    Date periode = Date.today().addDays(-daysOverdue);
    return Database.getQueryLocator([SELECT Id, StageName FROM Opportunity WHERE IsClosed = false AND CloseDate < :periode]);
   }

   public void execute(Database.BatchableContext context, List<Opportunity> targetedOpportunities){
    for(Opportunity opp : targetedOpportunities){
        opp.StageName = 'Closed Lost';
    }
    List<Database.SaveResult> results = Database.update(targetedOpportunities, false);
    for(Integer i = 0; i < results.size(); i++){
        if(results[i].isSuccess()){
            succeeded++;
        }else{
            failed++;
            System.debug(LoggingLevel.ERROR, 'Opportunity ' + targetedOpportunities[i].Id + ': ' + ': ' + results[i].getErrors()[0].getMessage());
        }
    }
   }
    public void finish(Database.BatchableContext context){
        System.debug('StaleOpportunityBatch done. Updated: ' + succeeded + ', failed: ' + failed);
    }

    public void execute(SchedulableContext context){
        Database.executeBatch(new StaleOpportunityBatch(daysOverdue), 200);
    }
}