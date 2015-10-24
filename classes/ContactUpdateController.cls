public without sharing class ContactUpdateController extends LeadFlowButtonHandler
{
    public String company { get; set; }
    public String city { get; set; }
    public String postCode { get; set; }
    public String phone { get; set; }
    public String mobilePhone { get; set; }
    public Boolean optOutOfEmails { get; set; }
    
    public ContactUpdateController(ApexPages.StandardController controller)
    {
        super(controller);
        company = lead.Company;
        city = lead.City;
        postCode = lead.PostalCode;
        phone = lead.Phone;
        mobilePhone = lead.MobilePhone;
        optOutOfEmails = lead.HasOptedOutOfEmail;
    }

    public PageReference UpdateContact()
    {
    	Boolean phoneIsInvalid = ! phone.startsWith('+') || phone.containsWhitespace() || phone.containsAny('-()#');
    	Boolean mobileIsInvalid = ! mobilePhone.startsWith('+') || mobilePhone.containsWhitespace() || mobilePhone.containsAny('-()#');
    	
    	if(phoneIsInvalid && ! String.IsBlank(phone))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Phone number must begin with a + sign and cannot contain spaces or special characters.'));

            return ApexPages.currentPage();
        }
        
        if(mobileIsInvalid && ! String.IsBlank(mobilePhone))
        {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Mobile phone number must begin with a + sign and cannot contain spaces or special characters.'));

            return ApexPages.currentPage();
        }
    	
    	lead.Company = company;
    	lead.City = city;
    	lead.PostalCode = postCode;
    	lead.Phone = phone;
    	lead.MobilePhone = mobilePhone;
    	lead.HasOptedOutOfEmail = optOutOfEmails;
    	
        update lead;
        return Util.RedirectTo(GetLeadId());
    }
}