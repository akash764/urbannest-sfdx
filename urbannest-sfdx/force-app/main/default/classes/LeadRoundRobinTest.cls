@isTest
private class LeadRoundRobinTest {

    private static User makeUser(String tag) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniq = String.valueOf(Crypto.getRandomInteger()).replace('-', '') + tag;
        return new User(Alias = 'rr' + tag, Email = 'rr' + uniq + '@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Rep' + tag, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_IN',
            ProfileId = p.Id, TimeZoneSidKey = 'Asia/Kolkata', Username = 'rr' + uniq + '@urbannest.test');
    }

    @isTest static void assignsToLeastLoadedRep() {
        User a = makeUser('A'); User b = makeUser('B');
        insert new List<User>{ a, b };
        LeadRoundRobin.repIdsOverride = new List<Id>{ a.Id, b.Id };

        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 4; i++) {
            leads.add(new Lead(LastName = 'Test' + i, Company = 'Website Enquiry', Phone = '98765432' + (10 + i)));
        }
        insert leads;

        List<LeadRoundRobin.Request> reqs = new List<LeadRoundRobin.Request>();
        for (Lead l : leads) { LeadRoundRobin.Request r = new LeadRoundRobin.Request(); r.leadId = l.Id; reqs.add(r); }
        Test.startTest();
        LeadRoundRobin.assign(reqs);
        Test.stopTest();

        Integer countA = [SELECT COUNT() FROM Lead WHERE OwnerId = :a.Id AND Id IN :leads];
        Integer countB = [SELECT COUNT() FROM Lead WHERE OwnerId = :b.Id AND Id IN :leads];
        System.assertEquals(4, countA + countB, 'All leads should be assigned to the two reps');
        System.assert(Math.abs(countA - countB) <= 1, 'Load should be balanced');
    }

    @isTest static void noRepsDoesNothing() {
        LeadRoundRobin.repIdsOverride = new List<Id>();
        Lead l = new Lead(LastName = 'Solo', Company = 'Website Enquiry', Phone = '9876543299');
        insert l;
        LeadRoundRobin.Request r = new LeadRoundRobin.Request(); r.leadId = l.Id;
        LeadRoundRobin.assign(new List<LeadRoundRobin.Request>{ r });
        System.assertEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Lead WHERE Id = :l.Id].OwnerId);
    }

    @isTest static void unitStatusFlowAndAvailabilityRule() {
        Project__c p = new Project__c(Name = 'Test Project', City__c = 'Chennai', State__c = 'Tamil Nadu');
        insert p;
        Block__c b = new Block__c(Name = 'Tower A', Project__c = p.Id);
        insert b;
        House_Unit__c u = new House_Unit__c(Name = '101', Block__c = b.Id, Unit_Type__c = '2 BHK', Area_SqFt__c = 900, Price__c = 6500000, Status__c = 'Available');
        insert u;
        Opportunity o1 = new Opportunity(Name = 'Deal 1', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), House_Unit__c = u.Id);
        insert o1;
        u.Status__c = 'Reserved'; update u;
        Opportunity o2 = new Opportunity(Name = 'Deal 2', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), House_Unit__c = u.Id);
        try { insert o2; System.assert(false, 'Should be blocked: unit not available'); }
        catch (DmlException e) { System.assert(e.getMessage().contains('not available')); }
    }
}
