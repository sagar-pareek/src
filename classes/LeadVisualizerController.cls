public class LeadVisualizerController {
    
    public lead ld{get;set;}
    public lead l {get;set;}
    public user opportunityOwner {get;set;}
    public opportunity o {get;set;} 
    
    public Map<String,DateTime>StageAndCreatedDateMap;
    public List<LeadHistory>listLeadHistory;
    
    public String ownerOfMQL {get;set;}
    public String ownerOfSAL {get;set;}
    public String ownerOfSQL {get;set;}
    
    public Boolean mql {get;set;}
    public Boolean sal {get;set;}
    public Boolean sql {get;set;}
    public Boolean srl {get;set;}
    public Boolean opp {get;set;}
    public Boolean sub {get;set;} 
    
    public LeadVisualizerController(ApexPages.StandardController controller) {
           opportunityOwner = new user();
           ld = (Lead)controller.getRecord();
           listLeadHistory = new List<LeadHistory>();
           l =[select id,Stage__c,Rejected__c,Status,DaysInMQL__c,DaysInSAL__c,DaysInSQL__c,DaysInSRL__c,DaysInSDL__c,ConvertedOpportunityId from lead where id=:ld.id limit 1];
           listLeadHistory = [SELECT CreatedDate,Field,Id,IsDeleted,LeadId,OldValue,NewValue FROM LeadHistory where  leadid=:ld.id  ORDER BY createdDate  ]; 
           StageAndCreatedDateMap = new Map<String,DateTime>();
           opportunityOwner = new user();
           
           mql = false;
           sal = false;
           sql = false;
           srl = false;
           opp = false;
           sub = false;
           
           
           for(LeadHistory lh : listLeadHistory){
                 if(lh.newvalue=='SRL' && lh.oldValue == 'MQL' && lh.field=='Stage__c'){
                     StageAndCreatedDateMap.put('MQL2SRL',lh.CreatedDate);
                     srl=true;
                     mql=true;
                 }
                 if(lh.newvalue=='SAL' && lh.oldValue == 'MQL' && lh.field=='Stage__c'){
                     StageAndCreatedDateMap.put('MQL2SAL',lh.CreatedDate);
                     sal=true;
                     mql=true;
                 }
                 if(lh.newvalue=='SRL' && lh.oldValue == 'SAL' && lh.field=='Stage__c'){
                     StageAndCreatedDateMap.put('SAL2SRL',lh.CreatedDate);
                     srl=true;
                     mql=true;
                     sal=true;
                 }
                 if(lh.newvalue=='SQL' && lh.oldValue == 'SAL' && lh.field=='Stage__c'){
                     StageAndCreatedDateMap.put('SAL2SQL',lh.CreatedDate);
                     sql=true;
                     mql=true;
                     sal=true;
                 }
                 if(lh.oldValue == 'SQL' && lh.field=='Stage__c'){
                     StageAndCreatedDateMap.put('SQL',lh.CreatedDate);
                     opp=true;                
                 }
                 
                 
                 
                             
           } 
            System.debug('MQL2SAL MAP'+StageAndCreatedDateMap);
            System.debug('leadhist'+listLeadHistory);
            System.debug('the value of mql2sal is'+StageAndCreatedDateMap.get('MQL2SAL'));
            //finding user logic begins here. finding owner between two stage dates.
           for(LeadHistory lh : listLeadHistory){
                         //MQL Stage code starts here
                         if(StageAndCreatedDateMap.get('MQL2SAL')!=null && StageAndCreatedDateMap.get('SAL2SRL')!=null  ){
                            if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SAL') && lh.CreatedDate<=StageAndCreatedDateMap.get('SAL2SRL') ){
                                ownerOfMQL = String.valueOf(lh.newvalue);
                            }else if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SAL') && lh.CreatedDate<=StageAndCreatedDateMap.get('SAL2SQL') ){
                                ownerOfMQL = String.valueOf(lh.newvalue);
                            }
                         }else if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SRL')){
                                ownerOfMQL = String.valueOf(lh.newvalue);
                         }
                         
                         //Cases of no range 
                         
                         else if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate<=StageAndCreatedDateMap.get('MQL2SAL') && StageAndCreatedDateMap.get('SAL2SRL')==null ){
                             ownerOfMQL = String.valueOf(lh.newvalue);
                         }
                         else if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate<=StageAndCreatedDateMap.get('MQL2SRL') && StageAndCreatedDateMap.get('MQL2SAL')==null  ){
                             ownerOfMQL = String.valueOf(lh.newvalue);
                         }
                             
                         //SAL Stage Code starts here.
                         
                         if(StageAndCreatedDateMap.get('MQL2SAL')!=null){
                             if(sal==true && sql==false){
                                 if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SAL') ){
                                     ownerOfSAL = String.valueOf(lh.newValue);
                                 }
                             }else if(sal==true && sql==true){
                                 if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SAL') && lh.CreatedDate<=StageAndCreatedDateMap.get('SAL2SQL') ){
                                     ownerOfSAL = String.valueOf(lh.newValue);
                                 }
                             
                             }else if(sal==true && srl==true){
                                 if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('MQL2SAL') && lh.CreatedDate<=StageAndCreatedDateMap.get('SAL2SRL') ){
                                     ownerOfSAL = String.valueOf(lh.newValue);
                                 }
                             
                             }
                         
                         }
                         
                       //SAL Stage Code ends here
                       
                       //Code block for the SQL Stage -- The last one!
                       
                       if(StageAndCreatedDateMap.get('SAL2SQL')!=null && sql==true){
                           if(lh.field=='Owner' && (!String.valueOf(lh.newvalue).startsWith('005')) && lh.CreatedDate>=StageAndCreatedDateMap.get('SAL2SQL') ){
                                     ownerOfSQL = String.valueOf(lh.newValue);
                                 }
                       
                       }  
                       
                      //Code block for the SQL Stage ends here. 
                      
                      
                      //Opportunity code block starts here
                      try{
                              if(l.ConvertedOpportunityId!=null){
                                  opp = true;
                                  o = [select id,StageName,OwnerId from opportunity where id=:l.ConvertedOpportunityId limit 1];
                              }
                              
                              if(o.OwnerId!=null){
                                  opportunityOwner =[select id,name from user where id=:o.OwnerId limit 1];
                              }    
                        }catch(Exception e){
                            System.debug('exception is '+e);
                        
                        }      
           }
      }        
}