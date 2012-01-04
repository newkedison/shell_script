#这个函数用于显示一个菜单,提示用户通过键盘选择其中一项,然后作为返回值提供给调用者
#输入参数必须大于2个,第一个参数是菜单标题,后面每个参数表示一个菜单项
#返回值可通过$?获取
#注意菜单项的文字长度不能大于30,否则须修改line_width变量的值为最大长度+10
#用法举例,下面两句可以显示一个菜单,在用户选择后,显示出选择的序号
#ShowMenu "main menu" "Add a new CD" "Find a CD(...)" "Delete a CD by Name" "Quit"
#echo $?
ShowMenu() {
  if [ $# -le 2 ]; then
    echo ShowMenu: Too few parameter
    exit 1
  fi
  local line_width=40 #每行宽度,所有行都会自动调整到这个长度
  local x=  #用于保存用户的输入
  local last_input=  #用户保存用户最后一次输入的内容,主要是用于提示用户输入有误
  local item_count=$(($# - 1)) #总共有几个菜单项
  local para=() #一个数组,用户缓存所有输入参数
  #这里用一个数组来缓存所有输入的参数,这样做的目的是,调用者输入的参数,可能大于9个,那么无法用$1-$9来获取
  #所以通过使用shift,把所有参数保存下来,后面就可以处理所有参数了,注意shift的操作会丢弃前面的参数,是不可逆的
  while [ -n "$1" ]; do
    para[$((${#para[*]}))]=$1 #每次把参数写入到数组后面的一个值,${#para[*]}是取得数组的长度
    shift 1
  done
  #用一个循环,确保用户选择了正确的选项
  while [ -z "$x" ]; do
    clear
    #下面显示第一行,如果标题为空,显示一行等号,否则,在中间插入标题
    local title=${para[0]}
    local tmp="========================================================" #这个临时变量用于方便后面截取固定长度的等号
    if [ -n "$title" ]; then #标题非空
      local title_len=$((${#title}+2)) #标题长度,前后各加一个空格,所以长度要+2
      local title_left=$((($line_width-$title_len) / 2)) #左边需要的等号个数
      local title_right=$(($line_width-$title_len - $title_left)) #右边需要的等号字数
      #echo ${tmp:0:$title_left}" $title "${tmp:0:$title_right} #这句相当于下面3句echo,但是为了看起来清楚,还是用下面的写法
      echo -n ${tmp:0:$title_left} #左边的等号
      echo -n " $title " #标题内容
      echo ${tmp:0:$title_right} #右边的等号
    else
      echo ${tmp:0:$line_width} #如果标题为空,那么就是一行等号
    fi

    local index=1 #当前菜单项的序号,会显示在每个菜单项之前
    tmp="                                                                 " #这里是方便后面截取固定长度的空格
    while [ -n "${para[$(($index))]}" ]; do #用一个循环处理所有菜单项
      local item=${para[$(($index))]} #菜单项内容
      local item_len=${#item} #菜单项长度
      local index_len=$((${#index} + 2)) #序号的长度,因为后面还有半个括号和一个空格,所以+2
      local left_space=$((5-${#index})) #序号左边的空格,这里默认序号最多为5位,剩下的内容补空格
      #右边的空格,其中5表示序号所占的位置(其中包括了左边的空格),一个2是序号右侧的半个括号和一个空格,第二个2是左右两侧各一个=号
      local right_space=$(($line_width - $item_len - 5 - 2 - 2))
      #同样,用下面的一句可以代替下面的7个echo,但为了看的清楚,还是拆开来
      #echo ="${tmp:0:$left_space}"$index") "$item"${tmp:0:$right_space}"=
      echo -n = #最左侧一个=号
      echo -n "${tmp:0:$left_space}" #序号左边的空格(注意要将双引号,不然空格就没了)
      echo -n $index #序号
      echo -n ") " #序号和菜单内容之间放半个括号和一个空格
      echo -n $item #菜单项
      echo -n "${tmp:0:$right_space}" #右侧剩余的空天填空格
      echo = #最后一个等号
      index=$(($index+1))
    done
    #这里是在最后一行加上一行等号,这样整个菜单看起来就像有一个边框一样了
    tmp="========================================================"
    echo ${tmp:0:$line_width}

    echo
    #如果已经不是第一次输入,那么显示上一次错误的输入内容
    if [ -n "$last_input" ]; then
      echo "Error Input: $last_input!"
    fi
    echo -n "Please input a number:"
    read x
    last_input=$x
    if [ -n "$x" ]; then
      #这里有3个判断,第一个判断输入必须是数字,后面两个判断必须在(0,菜单项个数]的范围内
      if [ -z ${x%%[0-9]*} ] && [ $x -gt 0 ] && [ $x -le $item_count ]; then
        return $x #如果满足要求,那么说明输入正确,返回用户选择了哪一项
      else
        x= #如果输入不合法,那么赋值为空,这样外面的循环才能循环下去
      fi
    else
      last_input=null #如果x为空,那么用一个null来表示
    fi
  done
}
