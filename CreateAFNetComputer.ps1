#Creating an AFNet Computer account: 


Add-DRAComputer 
    -Domain $env:AREA52
    –DRARestServer TDKP-RA-002V.AREA52.AFNOAPPS.USAF.MIL
    -DRARestPort 8755
    -DRAHostServer localhost
    -DRAHostPort 11192 
    -Properties @{DistinguishedName="CN=VDYDL-123XX1,OU=Barksdale AFB Computers,OU=Barksdale AFB,OU=AFCONUSWEST,OU=Bases,DC=AREA52,DC=AFNOAPPS,DC=USAF,DC=MIL”;Location="BLDG: 1700; RM: 300";AccountDisabled=$false;AccountThatCanAddComputerToDomain=”GLS_BARKSDALE_CFP-CSA,OU=Administrative Groups,OU=Administration, DC=AREA52,DC=AFNOAPPS,DC=USAF,DC=MIL”;o=”AFNIC”;l=”Scott AFB”} 
