/**
 * This class handles the assignment of a Lead owner based on User Lead Counter
 * and Weightage for priority. It sift through users in round robin manner.
 */
public without sharing class LeadOwnerAssigner
{
    private static Map <Id, User> assignedOwners = new Map <Id, User> ();

    private static Map <Id, Lead> updatedLeads = new Map <Id, Lead> ();
    
    /**
     * Assign owner to a lead using available Lead counter and profile weightage
     * on user's profile. Assignments are done in round robin manner.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    leadsList List of leads in context.
     * @return void
     */
    @InvocableMethod(label = 'Assign lead owner')
    public static void AssignLeadOwner(List<Lead> leadsList)
    {
        LeadOwnerAssigner assigner = new LeadOwnerAssigner();

        for (Lead LeadItem : leadsList)
        {
            if(LeadItem.CountryCode == null) continue;

            Lead freshLead = assigner.GetLeadWithRegion(LeadItem);

            // First we try to assign the lead owner by a matching lead, if no existing lead exist
            // or the owner cannot take this lead for any reason then we try to assign the lead 
            // to currently logged in user. If this user cannot take the lead either then we
            // fall back to the round robin assignment logic and find a user in territory.
            try
            {
                assigner.AssignLeadOwnerByMatchingLead(freshLead);
            }
            catch(RuntimeException noMatchingLeadException)
            {
                assigner.AssignLeadOwnerByWeightage(freshLead);
            }
        }
        
        List <User> allOwners = assignedOwners.values();
        List <Lead> allLeads = updatedLeads.values();
        
        update allOwners;
        update allLeads;
    }

    /**
     * Assign a lead owner by owner weightage.
     * 
     * @param lead Lead object to assign the lead owner for.
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    private void AssignLeadOwnerByWeightage(Lead lead)
    {
        Territory2 Territory = TerritoryDataAccess.GetLeadRegion(lead);

        List<UserTerritory2Association> usersInTerritory = TerritoryDataAccess.GetUserTerritoryPivots(Territory);

        if (usersInTerritory.size() < 1) return;
		
        User leadOwner = FindUserToAssignLead(usersInTerritory);

        AssignLeadToUser(lead, leadOwner.Id);
    }

    /**
     * Assign lead owner by previously matching lead.
     * 
     * @param lead Lead object to assign the lead owner using a similar lead.
     * @throws Exception If no matching lead is found.
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    private void AssignLeadOwnerByMatchingLead(Lead lead)
    {
        // Try to assign the lead to last lead owner. If no matching lead exists or the 
        // owner is no longer able to take this lead for any reason then try to assign
        // it to currently logged in user. Otherwise just throw the exception.
        try
        {    
            AssignLeadToLastLeadOwner(lead);            
        }
        catch(RuntimeException noMatchingLeadException)
        {
            if(CurrentUserTakesLeads(lead))
            {
                AssignLeadToUser(lead, UserInfo.getUserId());
            }
            else
            {
                throw noMatchingLeadException;                
            }
        }
    }
    
    /**
     * Try to assign the lead to a matching lead owner if one exists.
     * 
     * @param lead Lead object to assign the lead owner for. 
     * @return void
     * @throws RuntimeException if No matching lead was found or the lead 
     *                          cannot be assigned to last lead owner. 
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    private void AssignLeadToLastLeadOwner(Lead lead)
    {
        Lead lastLead = GetMatchingLead(lead);

        Territory2 lastLeadTerritory = TerritoryDataAccess.GetLeadRegion(lastLead);
        Territory2 currentLeadTerritory = TerritoryDataAccess.GetLeadRegion(lead);

        User lastLeadOwner = UserDataAccess.GetUser(lastLead.OwnerId);

        if(Matches(lastLeadTerritory, currentLeadTerritory) && UserTakesLead(lastLeadOwner, lead))
        {
            AssignLeadToUser(lead, lastLeadOwner.Id);
        }
        else
        {
            throw new RuntimeException('Cannot assign lead owner by matching leads.');
        }
    }
    
    /**
     * Check if a user takes leads.
     * 
     * @param user The user whose validity is being checked for lead assignment.
     * @param lead Lead object under question.
     * @return boolean
     * @author Mohammad Gufran <mohammad.gufran@kayako.com> 
     */
    private boolean UserTakesLead(User user, Lead lead)
    {
        try
        {
            Territory2 leadTerritory = TerritoryDataAccess.GetLeadRegion(lead);
            Set <Territory2> userTerritory = new Set <Territory2> (TerritoryDataAccess.GetUsersRegion(user.Id));

            // A use is considered to be eiligible to take leads only if the account
            // is active, account weightage is greater than 0 and the user belongs
            // to the same territory as the lead. Otherwise we throw and exception.
            return user.IsActive
                && user.KA_Weightage__c > 0
                && userTerritory.contains(leadTerritory);
        }
        catch(UnderflowException nullResultException)
        {
            return false;
        }
    }
    
    /**
     * Check if currently logged in user takes leads.
     * The Lead parameter is used to retrieve the "creator" of lead. 
     * 
     * @param lead Lead
     * @return boolean
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    private boolean CurrentUserTakesLeads(Lead lead)
    {
        // If current user is not associated with any territory Query will
        // throw an exception. If no exception is throws that means
        // We can assign the lead to current user. Otherwise not.
        return UserTakesLead(UserDataAccess.GetUser(UserInfo.getUserId()), lead);
    }
    
    /**
     * Get leads matching the given lead by email.
     * 
     * @param  lead Lead
     * @return Lead
     * @throws RuntimeException If no lead with a matching email exists 
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     */
    private Lead GetMatchingLead(Lead lead)
    {
        try
        {
            // Check if there is already a lead with same email and region.
            return LeadDataAccess.GetMatchingLeads(lead).get(0);
        }
        catch(UnderflowException nullResultException)
        {
            throw new RuntimeException('No matching lead exists for email ' + lead.Email);
        }
    }

    /**
     * Check to see if all the users have Zero lead counter, if yes then get the first
     * user from the top of the list as the list is already sorted in descending
     * order of Weightage. Otherwise get the user with minimum lead counter and
     * weightage more than zero.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    territoryUsers List<UserTerritory2Association>
     * @return User
     */
    private User FindUserToAssignLead(List<UserTerritory2Association> territoryUsers)
    {        
        if (AllUsersAreAtFullCapacity(territoryUsers))
        {
            ResetLeadCounters(territoryUsers);
        }

        // If all users have empty leads then just pick the first one as the list is already
        // sorted according to weightage. Otherwise get a user with minimum lead counter.
        if (AllUsersHaveEmptyLeads(territoryUsers))
        {
            return UserDataAccess.GetUser(territoryUsers.get(0));
        }
        else
        {
            return GetUserWithMinimumLeadCounter(territoryUsers);
        }
    }

    /**
     * Assign the lead to the user and increment relevant counters.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    lead Lead
     * @var    userId Id
     * @return void
     */
    private void AssignLeadToUser(Lead lead, Id userId)
    {
        lead.OwnerId = userId;
        User user = UserDataAccess.GetUser(userId);

        User owner = new User(Id = userId);

        Integer incrementedCounter = 1;

        if (user.KA_LeadCounter__c  != null || Integer.valueof(user.KA_LeadCounter__c ) == 0)
        {
            incrementedCounter = Integer.valueof(user.KA_LeadCounter__c ) + 1;
        }

        owner.KA_LeadCounter__c  = incrementedCounter;

        assignedOwners.put(owner.Id, owner);
    }

    /**
     * Check if all the users have Zero Lead Counter.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    territoryUsers List<UserTerritory2Association>
     * @return boolean
     */
    private boolean AllUsersHaveEmptyLeads(List<UserTerritory2Association> territoryUsers)
    {
        for (UserTerritory2Association UserTerritory : territoryUsers)
        {
            if (Integer.valueof(UserTerritory.User.KA_LeadCounter__c ) > 0) return false;
        }

        return true;
    }

    /**
     * Reset lead counter value of users
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    territoryUsers List<UserTerritory2Association>
     * @return void
     */
    private void ResetLeadCounters(List<UserTerritory2Association> territoryUsers)
    {
        List <User> people = new List <User> ();
        
        for (UserTerritory2Association Pivot : territoryUsers)
        {
            User person = UserDataAccess.GetUser(Pivot);

            person.KA_LeadCounter__c  = 0;

            people.add(person);
        }
        
        update people;
    }

    /**
     * Check if all the users in a territory are at their Lead capacity.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    territoryUsers List<UserTerritory2Association>
     * @return boolean
     */
    private boolean AllUsersAreAtFullCapacity(List<UserTerritory2Association> territoryUsers)
    {
        for (UserTerritory2Association Pivot : territoryUsers)
        {
            if (Integer.valueof(Pivot.User.KA_LeadCounter__c ) < Integer.valueof(Pivot.User.KA_Weightage__c))
            {
                return false;
            }
        }

        return true;
    }

    /**
     * Get a user with minimum lead counter.
     *
     * @author Mohammad Gufran <mohammad.gufran@kayako.com>
     * @var    territoryUsers List<User>
     * @return User
     */
    private User GetUserWithMinimumLeadCounter(List<UserTerritory2Association> territoryUsers)
    {
        User possibleOwner = UserDataAccess.GetUser(territoryUsers.get(0));
        territoryUsers.remove(0);

        for (UserTerritory2Association pivot : territoryUsers)
        {
            if (NextUserHasLessAssignments(possibleOwner, pivot))
            {
                possibleOwner = UserDataAccess.GetUser(pivot);
            }
        }

        return possibleOwner;
    }

    /**
     * Check if next user has lesser assignments than current user.
     * @param  possibleOwner User
     * @param  pivot         UserTerritory2Association
     * @return boolean
     */
    private boolean NextUserHasLessAssignments(User possibleOwner, UserTerritory2Association pivot)
    {
        return
               Integer.valueof(pivot.User.KA_LeadCounter__c ) < Integer.valueof(pivot.User.KA_Weightage__c)
            && Integer.valueof(pivot.User.KA_LeadCounter__c ) < Integer.valueof(possibleOwner.KA_LeadCounter__c );
    }
    
    /**
     * Assign territory ID to lead.
     * 
     * @param Lead lead
     * @return Lead
     * @author Mohammad Gufran <mohammad,.gufran@kayako.com>
     */
    private Lead GetLeadWithRegion(Lead lead)
    {
        Lead newLead = LeadDataAccess.GetLeadById(lead.Id);

        newLead.KA_Territory__c = TerritoryDataAccess.GetLeadRegion(lead).Name;
        
        updatedLeads.put(newLead.Id, newLead);
        
        return newLead;
    }
    
    /**
     * Varify that two objects are actually the same.
     * 
     * @param sObject first
     * @param sObject second
     * @returns boolean
     */ 
    private boolean Matches(sObject first, sObject second)
    {
        return first.Id == second.Id;
    }
}