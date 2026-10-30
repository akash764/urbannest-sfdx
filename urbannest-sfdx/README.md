# UrbanNest - Salesforce metadata (Sprint 1)

## Deploy (2 commands)
```bash
sf org login web --alias urbannest            # log in to your Developer Edition org
sf project deploy start --source-dir force-app --target-org urbannest --test-level RunLocalTests   # core
sf project deploy start --source-dir force-app-optional --target-org urbannest                     # stages + stage validation
```
Add `--dry-run` first to validate without saving.

## After deploy (manual, 5 minutes)
1. Setup > Permission Sets > UrbanNest Full Access > Manage Assignments > add yourself.
2. Setup > Public Groups > Sales Executives > add your sales users (leads are assigned to them).
3. Setup > Sharing Settings: Lead = Private, Opportunity = Private (Project/Block/House Unit are already Public Read Only).
4. Add the new fields to the Lead and Opportunity page layouts / Lightning record pages.
5. Setup > Duplicate Rules: clone the standard Lead rule (Phone/Email) so repeat enquiries are flagged.
6. Run scripts/apex/sample-data.apex in Execute Anonymous.

## What is inside
Objects: Project__c, Block__c, House_Unit__c (Project > Block > House Unit, master-detail)
Standard-object fields: Lead (6), Opportunity (3)
Validation rules: 5 core + 1 stage rule (optional folder)
Flows: Opportunity - Sync Unit Status, Lead - Assign Least Loaded Rep
Apex: LeadRoundRobin + tests; App: UrbanNest; Permission set: UrbanNest Full Access
Queue: New Leads; Public group: Sales Executives
