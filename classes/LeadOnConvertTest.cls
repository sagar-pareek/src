@isTest
public class LeadOnConvertTest{

    static testMethod void convertLead(){

        test.startTest();  //Telling system to refresh the test limits.

        Lead lead = new Lead();
        lead.FirstName ='TestLeadFirstName';
        lead.LastName = 'TestLeadLastName';
        lead.Company = 'Kayako';
        lead.LeadSource ='Online';
        lead.KA_Territory__c ='Americas';
        lead.Status = 'Qualified';
        lead.Stage__c = 'SQL';
        insert lead;   //Creating lead

        //Lead conversion process begins.
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

       // Making sure conversion was successful
       System.assert(lcr.isSuccess());

       test.stopTest(); // Telling system the test execution is over.

    }

}