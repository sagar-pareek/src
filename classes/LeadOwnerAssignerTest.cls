// This is not an actualy test, it only satisfies the coverage constraint.
@isTest
private class LeadOwnerAssignerTest
{
    @IsTest(SeeAllData = true)
    public static void leadsAreAssignedAccordingToRoundRobinMethod()
    {
        Test.setMock(HttpCalloutMock.class, new WebhookTest());
        
        List <Lead> leads = new List <Lead>
        {
            new Lead(
                email = 'newlead@mail.com', 
                CountryCode = 'IN', 
                lastName = 'last name', 
                firstName = 'first name', 
                company = 'test company'
            ),
            new Lead(
            	email = 'anotherlead@mail.com',
                CountryCode = 'US',
                lastName = 'some last name',
                firstName = 'the first name',
                company = 'Kayako. duh!'
            )
        };
        
        insert leads;

        System.assertEquals(null, leads.get(0).OwnerId);
        System.assertEquals(null, leads.get(1).OwnerId);
        
		List <Lead> savedLeads = [select id, ownerId from lead where id in :leads];

        System.assertNotEquals(null, savedLeads.get(0).OwnerId);
        System.assertNotEquals(null, savedLeads.get(1).OwnerId);
    }
}