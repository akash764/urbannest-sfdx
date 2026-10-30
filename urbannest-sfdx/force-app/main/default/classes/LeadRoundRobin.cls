public without sharing class LeadRoundRobin {

    public class Request {
        @InvocableVariable(required=true) public Id leadId;
    }

    @TestVisible private static List<Id> repIdsOverride;

    @InvocableMethod(label='Assign Leads (Least Loaded)' description='Assigns each lead to the Sales Executives group member with the fewest open leads')
    public static void assign(List<Request> requests) {
        List<Id> repIds = repIdsOverride != null ? repIdsOverride : queryReps();
        if (repIds.isEmpty() || requests == null || requests.isEmpty()) return;

        Map<Id, Integer> load = new Map<Id, Integer>();
        for (Id uid : repIds) load.put(uid, 0);
        for (AggregateResult ar : [SELECT OwnerId o, COUNT(Id) c FROM Lead
                                   WHERE IsConverted = false AND OwnerId IN :repIds GROUP BY OwnerId]) {
            load.put((Id) ar.get('o'), (Integer) ar.get('c'));
        }

        List<Lead> toUpdate = new List<Lead>();
        for (Request r : requests) {
            Id best; Integer min = 999999;
            for (Id uid : repIds) {
                if (load.get(uid) < min) { min = load.get(uid); best = uid; }
            }
            toUpdate.add(new Lead(Id = r.leadId, OwnerId = best));
            load.put(best, min + 1);
        }
        update toUpdate;
    }

    private static List<Id> queryReps() {
        List<Id> ids = new List<Id>();
        for (User u : [SELECT Id FROM User WHERE IsActive = true AND Id IN
                       (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Sales_Executives')]) {
            ids.add(u.Id);
        }
        return ids;
    }
}
