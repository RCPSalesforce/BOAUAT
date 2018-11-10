<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Limit</fullName>
        <field>Remaining_Credit_Balance__c</field>
        <formula>Account.Remaining_Credit_Balance__c - TotalAmount__c</formula>
        <name>Update Limit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Web_Portal_Status</fullName>
        <field>Web_Portal_Order_Status__c</field>
        <literalValue>WP-Cancelled</literalValue>
        <name>Update Web Portal Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Web_Portal_Status_to_Invoiced</fullName>
        <field>Web_Portal_Order_Status__c</field>
        <literalValue>Invoiced</literalValue>
        <name>Update Web Portal Status to Invoiced</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Remaining Credit Limit on Customer</fullName>
        <actions>
            <name>Update_Limit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Web_Portal_Order_Status__c</field>
            <operation>equals</operation>
            <value>Invoiced</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Web Portal Status</fullName>
        <actions>
            <name>Update_Web_Portal_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <description>update web portal field to WP-Cancelled on BOA Order when Stage changed to Closed Lost</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Web Portal Status when Closed won</fullName>
        <actions>
            <name>Update_Web_Portal_Status_to_Invoiced</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Change web portal order status to Invoiced when stage is Closed Won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
