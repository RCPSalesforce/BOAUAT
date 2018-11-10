<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Creation_Notification</fullName>
        <description>Contact Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Finance_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Contact_Creation</template>
    </alerts>
    <alerts>
        <fullName>Contact_Creation_Notification1</fullName>
        <description>Contact Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Finance_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Contact_Notification</template>
    </alerts>
    <rules>
        <fullName>New Contact Creation</fullName>
        <actions>
            <name>Contact_Creation_Notification1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Portal_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
