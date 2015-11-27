#!/usr/bin/awk -f
# Go to https://verrechnungsportal.hsr.ch/ and download the CSV containing all your badge transactions. 
# Then run this script like this: awk -f expense_analyzer.awk yourtransactions.csv

BEGIN {
  DECIMAL=substr(sprintf("%.2f",0),2,1);
  FS=";"
  CDEF="\033[39m"
  CRED="\033[31m"
  CGRE="\033[32m"
  CYEL="\033[33m"
  CBLU="\033[34m"
  BDEF="\033[43m"
  BDGR="\033[41m"
  TBOL="\033[1m"
  TDEF="\033[0m"

  TOTAL=0
}

{
  CATEGORY = $12
  PRODCOUNT = $11
  PRICE = $13 
  #sub(/\./, ",", PRICE)
  PRODUCT = $18
  CATEGORY = substr($17, 0, 4)
  ID = substr(PRODUCT, 0, 7)
  NAME = substr(PRODUCT, 11)
  if (PRICE >= 0 && $1 != "GeneratedTransaktionId")
  {
    TOTAL = TOTAL + PRICE
    if(CATEGORY == "0091") {
      NAME = "Druck / Kopie"
    } else if(CATEGORY == "0001") {
      NAME = "Essen"
    } else if(CATEGORY == "0002") {
      NAME = "Getraenk kalt"
    } else if(CATEGORY == "0004") {
      if(int(ID) >= 4001 && int(ID) <= 4005) {
        NAME = "Kaffee etc."
      } else if (ID == "0004007") {
        NAME = "Ovo / Schoggi"
      } else if (ID == "0004008") {
        NAME = "Tee"
      } 
    } else if(CATEGORY == "0005") {
      NAME = "Suessigkeiten"
    } else if(CATEGORY == "0008") {
      NAME = "Automat"
    }
    
    if (!(NAME in SUBTOTAL)) {
      SUBTOTAL[NAME] = 0
    }
    SUBTOTAL[NAME] = SUBTOTAL[NAME] + PRICE
    COUNT[NAME] = COUNT[NAME] + PRODCOUNT
  }

}

END {
  if(DECIMAL != ".") {
    print "\033[1;31mFEHLER: Your system is using \"" DECIMAL "\" als decimal mark with which the calculations won't work.\033[0m\nCall the script using " CBLU "LC_NUMERIC=C awk -f expense_analyzer.awk " FILENAME CDEF " instead."
    exit 1
  }
  
  print CBLU "=========================================================================="
  print "                           HSR Expense Analyzer"
  print "==========================================================================" CDEF
  printf "%s", TBOL
  printf "%-54s", "Product"
  printf "%-11s", "Amount"
  printf "%9s", "Total"
  printf "%s\n", TDEF
  print CBLU "--------------------------------------------------------------------------" CDEF
  for (id in SUBTOTAL) {
    printf "%-56s", id
    printf "%4d   ", COUNT[id]
    printf "CHF %7.2f\n", SUBTOTAL[id]
  }
  print CBLU "--------------------------------------------------------------------------" CDEF
  printf "%s", TBOL
  printf "%-63s", "TOTAL"
  printf "CHF %7.2f", TOTAL
  printf "%s\n", TDEF
  print CBLU "--------------------------------------------------------------------------" CDEF
}
