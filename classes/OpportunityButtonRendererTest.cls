@isTest
public class OpportunityButtonRendererTest 
{
    private static SObject opportunity;

    private static void createMock()
    {
        Test.setMock(HttpCalloutMock.class, new WebhookTest());
        
        opportunity = ObjectMocker.mock('Opportunity');
        opportunity.put('OwnerId', UserInfo.GetUserId());
        insert opportunity;
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
    }

    private static OpportunityButtonRenderer createRenderer()
    {
        ApexPages.StandardController controller = new ApexPages.StandardController(opportunity);
        return new OpportunityButtonRenderer(controller);
    }

    private static OpportunityButtonRenderer createHandler()
    {
        createMock();
        return createRenderer();
    }

    public static TestMethod void testConstructor()
    {
        createHandler();
    }

    public static TestMethod void testCanDemoOpportunity()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.VALUE_PROPOSITION);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanDemoOpportunity());
    }

    public static TestMethod void testCanProvideProposalAndQuoteInValueProposition()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.VALUE_PROPOSITION);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanProvideProposalAndQuote());
    }

    public static TestMethod void testCanProvideProposalAndQuoteInDemo()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.DEMO);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanProvideProposalAndQuote());
    }

    public static TestMethod void testCannotMarkAsLostIfLost()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.LOST);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert( ! handler.GetCanMarkAsLost());
    }

    public static TestMethod void testCannotMarkAsLostIfWon()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.WON);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert( ! handler.GetCanMarkAsLost());
    }

    public static TestMethod void testCanMarkAsWonInReviewAndNegotiation()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.REVIEW_AND_NEGOTIATION);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assertEquals(UserDataAccess.GetCurrentUser().Profile.Name == 'System Administrator', handler.GetCanMarkAsWon());
    }

    public static TestMethod void testCanMarkAsWonInProposalAndQuote()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.PROPOSAL_AND_QUOTE);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();
		
        System.assertEquals(UserDataAccess.GetCurrentUser().Profile.Name == 'System Administrator', handler.GetCanMarkAsWon());
    }

    public static TestMethod void testCanReviewAndNegotiate()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.PROPOSAL_AND_QUOTE);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanReviewAndNegotiate());
    }

    public static TestMethod void testCanProvideNewQuote()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.PROPOSAL_AND_QUOTE);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanProvideNewQuote());
    }
    
    public static TestMethod void testCanUpdateInstance()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.PROPOSAL_AND_QUOTE);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert(handler.GetCanUpdateInstanceDetails());
    }
    
    public static TestMethod void testCannotUpdateInstanceIfWon()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.WON);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert( ! handler.GetCanUpdateInstanceDetails());
    }
    
    public static TestMethod void testCannotUpdateInstanceIfLost()
    {
        createMock();
        opportunity.put('StageName', OpportunityStage.LOST);
        update opportunity;
        OpportunityButtonRenderer handler = createRenderer();

        System.assert( ! handler.GetCanUpdateInstanceDetails());
    }
    
    public static TestMethod void TestDemoOpportunity()
    {
        OpportunityButtonRenderer handler = createHandler();
        PageReference response = handler.DemoOpportunity();
        Opportunity subject = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert(subject.StageName == OpportunityStage.DEMO);
    }

    public static TestMethod void testProposalAndQuoteGiven()
    {
        OpportunityButtonRenderer handler = createHandler();
        PageReference response = handler.ProvideProposalAndQuote();
        Opportunity subject = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert(subject.StageName == OpportunityStage.PROPOSAL_AND_QUOTE);
    }

    public static TestMethod void testOpportinityIsLost()
    {
        OpportunityButtonRenderer handler = createHandler();
        PageReference response = handler.MarkAsLost();
        Opportunity subject = [SELECT Id, StageName, ClosedBy__c FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];

        System.assertEquals('Agent', subject.ClosedBy__c);
        System.assertEquals(OpportunityStage.LOST, subject.StageName);
    }

    public static TestMethod void testOpportunityIsWon()
    {
        OpportunityButtonRenderer handler = createHandler();
        PageReference response = handler.MarkAsWon();
        Opportunity subject = [SELECT Id, StageName, ClosedBy__c FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];

        System.assertEquals('Agent', subject.ClosedBy__C);
        System.assertEquals(OpportunityStage.WON, subject.StageName);
    }

    public static TestMethod void testReviewAndNegotiate()
    {
        OpportunityButtonRenderer handler = createHandler();
        PageReference response = handler.ReviewAndNegotiate();
        Opportunity subject = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunity.Id LIMIT 1];
        System.assert(subject.StageName == OpportunityStage.REVIEW_AND_NEGOTIATION);
    }
}