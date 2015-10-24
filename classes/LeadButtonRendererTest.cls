@isTest
public class LeadButtonRendererTest 
{
    private static SObject lead;

    private static void createMock()
    {
        Test.setMock(HttpCalloutMock.class, new WebhookTest());
        lead = ObjectMocker.mock('Lead');
        lead.put('OwnerId', UserInfo.GetUserId());
        lead.put('PreviousOwner__c', UserInfo.GetUserId());
        lead.put('Stage__c','Qualified');
        lead.put('Phone','+1634728678');
        lead.put('MobilePhone','+1634728678');
        insert lead;
        ApexPages.currentPage().getParameters().put('id', lead.Id);
    }

    private static LeadButtonRenderer createRenderer()
    {
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        return new LeadButtonRenderer(controller);
    }

    private static LeadButtonRenderer createHandler()
    {
        createMock();
        return createRenderer();
    }

    public static TestMethod void AcceptOpenLeads()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.AcceptOpenLead();

        System.assert(LeadStage.SAL == [SELECT Stage__c FROM Lead WHERE Id = :lead.Id].Stage__c);
        System.assert(response.getRedirect());
    }

    public static TestMethod void RejectOpenLeads()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.RejectOpenLead();

        System.assert(LeadStage.SRL == [SELECT Stage__c FROM Lead WHERE Id = :lead.Id].Stage__c);
        System.assert(LeadStatus.NURTURE == [SELECT Status FROM Lead WHERE Id = :lead.Id].Status);
        System.assert(response.getRedirect());
    }

    public static TestMethod void MarkLeadContacted()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.MarkLeadContacted();

        System.assert(LeadStatus.CONTACTED == [SELECT Status FROM Lead WHERE Id = :lead.Id].Status);
        System.assert(response.getRedirect());
    }

    public static TestMethod void MarkLeadUnresponsive()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.MarkLeadUnresponsive();

        System.assert(LeadStatus.UNRESPONSIVE == [SELECT Status FROM Lead WHERE Id = :lead.Id].Status);
        System.assert(response.getRedirect());
    }

    public static TestMethod void MarkLeadResponsive()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.MarkLeadResponsive();

        System.assert(LeadStatus.CONTACTED == [SELECT Status FROM Lead WHERE Id = :lead.Id].Status);
        System.assert(response.getRedirect());
    }

    public static TestMethod void RejectAcceptedLead()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.RejectAcceptedLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        System.assert(LeadStatus.NURTURE == changed.Status);
        System.assert(LeadStage.SRL == changed.Stage__c);
        System.assert(response.getRedirect());
    }

	/** // Removing this function because of changes in SF API summer'15
    public static TestMethod void AcceptInterestedLead()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.AcceptInterestedLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        System.assert(LeadStatus.QUALIFIED == changed.Status);
        System.assert(LeadStage.SQL == changed.Stage__c);
        System.assert(response.getRedirect());
    }
	*/

    public static TestMethod void RejectInterestedLead()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.RejectInterestedLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        System.assert(LeadStatus.NURTURE == changed.Status);
        System.assert(LeadStage.SDL == changed.Stage__c);
        System.assert(response.getRedirect());
    }

    public static TestMethod void ReturnInterestedLead()
    {
        createMock();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        SObject user = ObjectMocker.mock('User');
        user.put('username', 'user' + String.valueOf(Math.random()) + '@example' + String.valueOf(Math.random()) + '.com');
        user.put('ProfileId', profile.Id);
        insert user;

        lead.put('OwnerId', user.Id);
        lead.put('PreviousOwner__c', user.Id);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        PageReference response = handler.ReturnInterestedLead();

        Lead changed = [SELECT Status, Stage__c, PreviousOwner__c, OwnerId FROM Lead WHERE Id = :lead.Id];
        System.assert(LeadStatus.CONTACTED == changed.Status);
        System.assert(LeadStage.SAL == changed.Stage__c);
        System.assert(changed.PreviousOwner__c == lead.get('OwnerId'));
        System.assert(changed.OwnerId == lead.get('PreviousOwner__c'));

        System.assert(response.getRedirect());
    }

    public static TestMethod void RejectQualifiedLead()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.RejectQualifiedLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        System.assert(LeadStatus.NURTURE == changed.Status);
        System.assert(LeadStage.SDL == changed.Stage__c);

        System.assert(response.getRedirect());
    }
    
    public static TestMethod void CloseQualifiedLead()
    {
        LeadButtonRenderer handler = createHandler();
        PageReference response = handler.CloseQualifiedLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        
        System.assertEquals(LeadStatus.DEAD, changed.Status);
        System.assertEquals(LeadStage.SDL, changed.Stage__c);
        System.assert(response.getRedirect());
    }
    
    /** // disabling this method because of changes in summer'15 release
    public static TestMethod void ReopenClosedLead()
    {
        createMock();
		lead.put('Stage__c', LeadStage.SDL);
        lead.put('Status', LeadStatus.NURTURE);
        update lead;
        
        LeadButtonRenderer handler = createRenderer();
        PageReference response = handler.ReopenLead();
        Lead changed = [SELECT Status, Stage__c FROM Lead WHERE Id = :lead.Id];
        
        System.assertEquals(LeadStatus.QUALIFIED, changed.Status);
        System.assertEquals(LeadStage.SQL, changed.Stage__c);
        System.assert(response.getRedirect());
    }
    */

    public static TestMethod void CanAcceptOpenLeads()
    {
        createMock();
        lead.put('Stage__c', LeadStage.MQL);
        lead.put('Status', LeadStatus.OPEN);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanAcceptOpenLead());
    }

    public static TestMethod void CanRejectOpenLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.MQL);
        lead.put('Status', LeadStatus.OPEN);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanRejectOpenLead());
    }

    public static TestMethod void CanMarkLeadContacted()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.OPEN);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanMarkLeadContacted());
    }

    public static TestMethod void CanSetTerritory()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('KA_Territory__c', null);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanSetTerritory());
    }

    public static TestMethod void CanQualifyLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.CONTACTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanQualifyLead());
    }

    public static TestMethod void CanEnrichLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.CONTACTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanEnrichLead());
    }

    public static TestMethod void CanUpdateContact()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.CONTACTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanUpdateContact());
    }

    public static TestMethod void CanMarkLeadUnresponsive()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.OPEN);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanMarkLeadUnresponsive());
    }

    public static TestMethod void CanMarkLeadResponsive()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.UNRESPONSIVE);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanMarkLeadResponsive());
    }

    public static TestMethod void CanRejectAcceptedLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.CONTACTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanRejectAcceptedLead());
    }

    /*
    @isTest(SeeAllData = true) 
    public static void CanAcceptInterestedLead()
    {
        Territory2 country = SetupTerritory();

        createMock();
        lead.put('CountryCode', country.DeveloperName);
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.INTERESTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanAcceptInterestedLead());
    }

    @isTest(SeeAllData = true) 
    public static void CanRejectInterestedLead()
    {
        Territory2 country = SetupTerritory();

        createMock();
        lead.put('CountryCode', country.DeveloperName);
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.INTERESTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanRejectInterestedLead());
    }

    @isTest(SeeAllData = true) 
    public static void CanReturnInterestedLead()
    {
        Territory2 country = SetupTerritory();

        createMock();
        lead.put('CountryCode', country.DeveloperName);
        lead.put('Stage__c', LeadStage.SAL);
        lead.put('Status', LeadStatus.CONTACTED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanReturnInterestedLead());
    }

    @isTest(SeeAllData = true) 
    public static void CanConvertToOpportunity()
    {
        Territory2 country = SetupTerritory();

        createMock();
        lead.put('CountryCode', country.DeveloperName);
        lead.put('Stage__c', LeadStage.SQL);
        lead.put('Status', LeadStatus.QUALIFIED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanConvertToOpportunity());
    }

    @isTest(SeeAllData = true) 
    public static void CanRejectQualifiedLead()
    {
        Territory2 country = SetupTerritory();
        
        createMock();
        lead.put('CountryCode', country.DeveloperName);
        lead.put('Stage__c', LeadStage.SQL);
        lead.put('Status', LeadStatus.QUALIFIED);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanRejectQualifiedLead());
    }
    */
    
    @IsTest
    public static void CanReopenRejectedLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SRL);
        lead.put('Status', LeadStatus.NURTURE);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanReopenLead());
    }
    
    @IsTest
    public static void CanReopenDisqualifiedLead()
    {
        createMock();
        lead.put('Stage__c', LeadStage.SDL);
        lead.put('Status', LeadStatus.NURTURE);
        update lead;

        LeadButtonRenderer handler = createRenderer();
        System.assert(handler.GetCanReopenLead());
    }


    private static Territory2 SetupTerritory()
    {
        Id regionsTypeId = [SELECT Id FROM Territory2Type WHERE DeveloperName = 'Countries' LIMIT 1].Id;
        Territory2 country = [SELECT Id, ParentTerritory2.Id, DeveloperName FROM Territory2 WHERE Territory2Type.Id = :regionsTypeId LIMIT 1];

        UserTerritory2Association association = new UserTerritory2Association(
            Territory2Id = country.ParentTerritory2.Id,
            UserId = UserInfo.GetUserId(),
            RoleInTerritory2 = RoleName.ISM
        );

        insert association;

        return country;
    }
}