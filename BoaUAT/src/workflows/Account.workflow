<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Customer_Creation_Email_Notification</fullName>
        <description>New customer creation  email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Customer_Creation_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Alert</fullName>
        <ccEmails>krutika.bhavsar@centelon.com</ccEmails>
        <description>Send Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>rohit.pund@centelon.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Onboarding_closure_date_alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Geo Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.ShippingStreet</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>GeoUpdate</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.ShippingStreet</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Customer Creation Email Notification</fullName>
        <actions>
            <name>New_Customer_Creation_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Enterprise Customer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email Before 1 Week of Target Closure Date</fullName>
        <actions>
            <name>Send_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Onboarding_Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Account.Onboarding_Target_Closure_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Credit_Check_Application_Sent</fullName>
        <assignedTo>integration.user@centelon.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Credit Check Application Sent</subject>
    </tasks>
</Workflow>
