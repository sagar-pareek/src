@isTest
public class ContactUpdateControllerTest
{
    public static TestMethod void UpdateContactOnLead()
    {
        SObject lead = ObjectMocker.mock('Lead');
        insert lead;
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        ContactUpdateController handler = new ContactUpdateController(controller);

        handler.company = 'company';
	    handler.city = 'some city'; 
	    handler.postCode = '12345';
	    handler.phone = '+123456789';
	    handler.mobilePhone = '+123456789';
	    handler.optOutOfEmails = true;

        PageReference response = handler.UpdateContact();

        
    }
    
    public static TestMethod void UpdateContactOnLeadInvalidPhoneNumber()
    {
        SObject lead = ObjectMocker.mock('Lead');
        insert lead;
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        ContactUpdateController handler = new ContactUpdateController(controller);

        handler.company = 'company';
	    handler.city = 'some city'; 
	    handler.postCode = '12345';
	    handler.phone = '123456789';
	    handler.mobilePhone = '123456789';
	    handler.optOutOfEmails = true;

        PageReference response = handler.UpdateContact();

        
    }
}