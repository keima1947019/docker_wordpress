CERT_KANEPON_COM="prx/crt/kanepon.com.crt"
echo "kanepon.com"
openssl x509 -text -noout -in ${CERT_KANEPON_COM} | grep Validity -A2
echo "*.kanepon.com"
CERT_WILDCARD_KANEPON_COM="prx/crt/wildcard.kanepon.com.crt"
openssl x509 -text -noout -in ${CERT_WILDCARD_KANEPON_COM} | grep Validity -A2
