@isTest
private class StaleOpportunityBatchTest {

    private static Opportunity makeOpp(String name, String stage, Date closeDate) {
        return new Opportunity(Name = name, StageName = stage, CloseDate = closeDate);
    }

    @isTest
    static void closesOnlyOverdueOpenOpportunities() {
        // Arrange
        Opportunity stale = makeOpp('Stale', 'Prospecting', Date.today().addDays(-120));
        Opportunity fresh = makeOpp('Fresh', 'Prospecting', Date.today().addDays(10));
        insert new List<Opportunity>{ stale, fresh };

        // Act
        Test.startTest();
        Database.executeBatch(new StaleOpportunityBatch(90));
        Test.stopTest();

        // Assert
        System.assertEquals('Closed Lost',
            [SELECT StageName FROM Opportunity WHERE Id = :stale.Id].StageName);
        System.assertEquals('Prospecting',
            [SELECT StageName FROM Opportunity WHERE Id = :fresh.Id].StageName);
    }

    @isTest
    static void leavesAlreadyClosedOpportunitiesAlone() {
        Opportunity won = makeOpp('Won', 'Closed Won', Date.today().addDays(-200));
        insert won;

        Test.startTest();
        Database.executeBatch(new StaleOpportunityBatch(90));
        Test.stopTest();

        System.assertEquals('Closed Won',
            [SELECT StageName FROM Opportunity WHERE Id = :won.Id].StageName);
    }

    @isTest
    static void handlesTwoHundredRecords() {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opps.add(makeOpp('Stale ' + i, 'Prospecting', Date.today().addDays(-120)));
        }
        insert opps;

        Test.startTest();
        Database.executeBatch(new StaleOpportunityBatch(90), 200);
        Test.stopTest();

        System.assertEquals(200,
            [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Lost']);
    }

    @isTest
    static void schedulerStartsTheBatch() {
        Test.startTest();
        String jobId = System.schedule('Test Stale Cleanup', '0 0 2 * * ?',
                                       new StaleOpportunityBatch());
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }
}