#!/bin/bash

ASN=$1

whois -h whois.cymru.com " -f as$ASN "

exit 0

