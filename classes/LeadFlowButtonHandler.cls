public without sharing abstract class LeadFlowButtonHandler
{
    ApexPages.StandardController LeadController;
    
    public List<ActivityHistory>leadTaskList = new List<ActivityHistory>();
   
    
    
    public boolean flagUnresponsive{get;set;}    
    protected Lead lead;

    protected User user;

    public LeadFlowButtonHandler(ApexPages.StandardController controller)
    {
        flagUnresponsive = false;
        LeadController = controller;
        lead = LeadDataAccess.getLeadById(getLeadId());
        user = UserDataAccess.GetCurrentUser();
        
        for (lead l :[select (select ActivityType,IsTask from ActivityHistories ) from Lead where id=:GetLeadId()]){
            for(ActivityHistory ah :l.ActivityHistories){
                System.debug('The activity type is'+ah.ActivityType);
                if(ah.ActivityType=='Other' || ah.ActivityType=='Call' || ah.ActivityType=='1_'){
                    leadTaskList.add(ah);
                }           
                
            }
            
            }
        if(leadTaskList.size()<2){
            flagUnresponsive = true;        
        }
    }

    protected Id GetLeadId()
    {
        return ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference AcceptOpenLead()
    {
        lead.Stage__c = LeadStage.SAL;
        lead.StageToSALDate__c = Date.today();
        lead.StageLastUpdatedDate__c = Date.today();

        if(lead.OwnerId == null)
        {
            lead.OwnerId = user.Id;
        }

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference RejectOpenLead()
    {
        lead.Stage__c = LeadStage.SRL;
        lead.Status = LeadStatus.NURTURE;
        lead.StageLastUpdatedDate__c = Date.today();
        lead.StageToSRLDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference MarkLeadContacted()
    {
        lead.Status = LeadStatus.CONTACTED;
        lead.StatusToContactedDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference MarkLeadInterested()
    {
        Territory2 leadTerritory = TerritoryDataAccess.GetLeadRegion(lead);
        String role = TerritoryDataAccess.GetUserRole(user, leadTerritory);

        Id currentOwner = lead.OwnerId;
        
        // If user is an ADM and does not have a Manager, we cannot assign the lead to
        // anybody. In this case just show them an error so that they can talk to the
        // person responsible for assigning the manager to ADM.
        if(role.equals(RoleName.ADM))
        {
            if(user.ManagerId == null)
            {
                lead.addError('You do not have a manager assigned to handle interested leads, therefor the lead cannot be marked as interested.');
                return Util.RedirectTo(GetLeadId());
            }

            lead.OwnerId = user.ManagerId;
        }

        lead.PreviousOwner__c = currentOwner;
        
        lead.StatusToInterestedDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();
        lead.Status = LeadStatus.INTERESTED;

        update lead;

        return Util.RedirectTo(GetLeadId());
    }
    
    public PageReference CannotMarkLeadUnresponsive()
    {
        PageReference pg = new PageReference('/'+getLeadId());
        return pg;
        
    }
    
    public PageReference MarkLeadUnresponsive()
    {
            
        
            
            
            
                lead.Status = LeadStatus.UNRESPONSIVE;
                lead.StatusLastUpdatedDate__c = Date.today();
                lead.StatusToUnresponsiveDate__c = Date.today();
        
                update lead;
        
                return Util.RedirectTo(GetLeadId());
            
            
            
            
    }

    public PageReference MarkLeadResponsive()
    {
        lead.Status = LeadStatus.CONTACTED;
        lead.StatusLastUpdatedDate__c = Date.today();
        lead.StatusToContactedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference RejectAcceptedLead()
    {
        lead.Status = LeadStatus.NURTURE;
        lead.Stage__c = LeadStage.SRL;
        lead.StageLastUpdatedDate__c = Date.today();
        lead.StageToSRLDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference AcceptInterestedLead()
    {
        lead.Status = LeadStatus.QUALIFIED;
        lead.Stage__c = LeadStage.SQL;
        lead.StatusToQualifiedDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference RejectInterestedLead()
    {
        lead.Status = LeadStatus.NURTURE;
        lead.Stage__c = LeadStage.SDL;
        lead.StageToSDLDate__c = Date.today();
        lead.StatusToNurtureDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference ReturnInterestedLead()
    {
        lead.Status = LeadStatus.CONTACTED;
        lead.Stage__c = LeadStage.SAL;
        lead.StatusToContactedDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();
        
        Id previousOwner = lead.PreviousOwner__c;
        lead.PreviousOwner__c = lead.OwnerId;
        lead.OwnerId = previousOwner;
        
        update lead;

        return Util.RedirectTo(GetLeadId());
    }

    public PageReference RejectQualifiedLead()
    {
        lead.Status = LeadStatus.NURTURE;
        lead.Stage__c = LeadStage.SDL;
        lead.StageToSDLDate__c = Date.today();
        lead.StatusToNurtureDate__c = Date.today();
        lead.StatusLastUpdatedDate__c = Date.today();

        update lead;

        return Util.RedirectTo(GetLeadId());
    }
    
    public PageReference CloseQualifiedLead()
    {
        lead.Stage__c = LeadStage.SDL;
        lead.Status = LeadStatus.DEAD;
        lead.StatusLastUpdatedDate__c = Date.today();
        lead.StageToSDLDate__c = Date.today();
        
        update lead;
        
        return Util.RedirectTo(GetLeadId());
    }
    
    public PageReference ReopenLead()
    {
        String currentStage = lead.Stage__c;
        
        if(currentStage == LeadStage.SDL)
        {
            lead.Stage__c = LeadStage.SQL;
            lead.Status = LeadStatus.QUALIFIED;
        }
        else if(currentStage == LeadStage.SRL)
        {
            lead.Stage__c = LeadStage.SAL;
            lead.Status = LeadStatus.OPEN;
        }
        
        update lead;
        
        return Util.RedirectTo(GetLeadId());
    }
}