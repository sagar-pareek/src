public class CreateNewLeadController
{
    public ApexPages.StandardController LeadController;
    
	public CreateNewLeadController(ApexPages.StandardController controller)
    {
        LeadController = controller;
    }
    
    public PageReference save()
    {
		Lead currentLead = (Lead) LeadController.getRecord();
        currentLead.CreationStage__c = LeadStage.SAL;
        
        String phone = currentLead.Phone;
        
        if( ! phone.startsWith('+') || phone.containsWhitespace() || phone.containsAny('-()#'))
        {
            currentLead.Phone.addError('Phone number must start with a \'+\' symbol and can contain only digits after that.');
            
            return ApexPages.currentPage();
        }
        
		currentLead.FirstName = Util.SentenceCase(currentLead.FirstName);
        currentLead.LastName = Util.SentenceCase(currentLead.LastName);
        currentLead.Company = Util.SentenceCase(currentLead.Company);
        
        return LeadController.save();
    }
}