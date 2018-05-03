export LC_CTYPE=C
export LANG=C
RED='\033[0;31m'
NC='\033[0m' # No Color

source 'user.conf'

domain=https://coes-stud.must.edu.mo
coesUrl="$domain/coes"
loginUrl="$coesUrl/login.do"

echo '正在初始化...'
rm cookies
rm *.html
curl -c cookies $loginUrl > 1.html
jsessionid=$(awk -v f='JSESSIONID' '$0 ~ f {for (i=2; i<=NF; i++) if ($(i-1)==f) {print $i; exit}}' cookies)
token=$(cat 1.html | grep -o 'org.apache.struts.taglib.html.TOKEN" value=\".*\"' | grep -o "value=".*"" | sed -n 's/value=//p' | sed -e 's:"::g')

echo -e "已获取jsessionid=${RED}$jsessionid${NC}"
echo -e "已获取token=${RED}$token${NC}"

echo -e "初始化成功"

if [[ -z "${userid}" ]]; then
  echo '请输入学号(1X09853X-XXXX-XXXX):'
  read userid
  echo userid=$userid >> user.conf
fi
echo "已获取学号: $userid"
if [[ -z "${password}" ]]; then
  echo '请输入密码:'
  read password
  echo password=$password >> user.conf
fi
echo "已获取密码: $password"

crsCode=

curl "$loginUrl;jsessionid=$jsessionid" -H 'Pragma: no-cache' -H 'Origin: '$domain -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: no-cache' -H "Referer: $loginUrl" -H "Cookie: JSESSIONID=$jsessionid" -H 'Connection: keep-alive' -H 'DNT: 1' --data "org.apache.struts.taglib.html.TOKEN=$token&userid=$userid&password=$password&submit=%E7%99%BB%E5%85%A5" --compressed > 2.html

alert=$(grep -o 'alert(\".*\");' 2.html)
if [ -n "$alert" ]; then
  echo "登录失败"
  echo -e "失败原因：$RED$alert$NC" && exit 0
else
  echo "登录成功"
fi

crsCode='INB411-002'
crsIntake='1809'
clsCode='E1'

watch -n1 -x curl 'https://coes-stud.must.edu.mo/coes/EnrollmentClass.do' -H 'Pragma: no-cache' -H 'Origin: https://coes-stud.must.edu.mo' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'Referer: https://coes-stud.must.edu.mo/coes/EnrollmentCourse.do' -H "Cookie: JSESSIONID=$jsessionid; _ga=GA1.3.1240678185.1522729737; UM_distinctid=16289c52d31405-030a61373ada73-336c7b05-100200-16289c52d335b4; __utma=45188152.1240678185.1522729737.1522753020.1523060229.3; __utmz=45188152.1523060229.3.3.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided)" -H 'Connection: keep-alive' -H 'DNT: 1' --data "formAction=TakeClassSubmit&crsCode=$crsCode&exempt=N&crsIntake=$crsIntake&clsCode=$clsCode" --compressed
