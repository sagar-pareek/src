@isTest
public class CreateNewLeadControllerTest
{
	public static TestMethod void createNewLead()
    {
		// override callout.
        Test.setMock(HttpCalloutMock.class, new WebhookTest());

        SObject lead = ObjectMocker.mock('Lead');
        lead.put('Phone', '+9192939495');
        lead.put('firstName', 'some name');
        lead.put('lastName', 'last name');
        lead.put('company', 'company name');
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(lead);
        CreateNewLeadController controller = new CreateNewLeadController(standardController);
        
        PageReference response = controller.save();
        
        System.assertEquals(response.getParameters().get('id'), lead.Id);
    }
    
	public static TestMethod void errorOnInvalidPhone()
    {
		// override callout.
        Test.setMock(HttpCalloutMock.class, new WebhookTest());

        Lead lead = (Lead) ObjectMocker.mock('Lead');
        lead.Phone = '91-929 (39) 495';
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(lead);
        CreateNewLeadController controller = new CreateNewLeadController(standardController);
        
        PageReference response = controller.save();
        
		System.assert(response.getRedirect());
        System.assert(ApexPages.getMessages().get(0).getSummary() == 'Phone number must start with a \'+\' symbol and can contain only digits after that.');
    }
}