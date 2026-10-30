// Run in Developer Console > Debug > Open Execute Anonymous Window
Project__c p = new Project__c(Name='Sample Heights', City__c='Chennai', State__c='Tamil Nadu',
    Locality__c='OMR', Status__c='Ongoing', Possession_Date__c=Date.today().addMonths(18), RERA_Number__c='TN/XX/SAMPLE');
insert p;
Block__c b = new Block__c(Name='Tower A', Project__c=p.Id);
insert b;
List<House_Unit__c> units = new List<House_Unit__c>();
String[] types = new String[]{'1 BHK','2 BHK','3 BHK'};
for (Integer i = 0; i < 9; i++) {
    units.add(new House_Unit__c(
        Name = String.valueOf(101 + i), Block__c = b.Id,
        Unit_Type__c = types[Math.mod(i,3)], Area_SqFt__c = 600 + (Math.mod(i,3) * 300),
        Floor__c = 1 + (i / 3), Price__c = 4500000 + (Math.mod(i,3) * 2000000),
        Facing__c = 'East', Status__c = 'Available'));
}
insert units;
System.debug('Created project, 1 block, ' + units.size() + ' units');
