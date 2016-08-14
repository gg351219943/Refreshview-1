# Refreshview
自定义下拉刷新，上拉加载


![image](https://github.com/wangzhangjie/Refreshview/blob/master/Untitled.gif)   


# to do
很多列表需要下拉刷新，上拉加载这样的功能。但是图片大都需要自定义，对摆放的位置也会有不同的要求，而且还需要集成简单


# how to use

step 1， 声明一个变量 ：   var myRefreshview : RefreshView? = nil

step 2， 初始化这个变量 ： myRefreshview = tableview.addRefreshControl(myloading)  //myloading是自定义的图片数组

step 3， 开始下拉刷新  :   myRefreshview?.beginRefresh()


step 4,  下拉刷新和上拉加载的操作(需要在这2个代理方法里写，但步影响你的正常业务逻辑) ：


                           func scrollViewDidScroll(scrollView: UIScrollView){
                                     self.myRefreshview?.freshviewDidScroll(scrollView)
       
                            }
                           func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
        
                                    self.myRefreshview?.freshviewDidEndDragging({
            
                                    ／／这里是下拉刷新的操作
                                    }, yourUpPullAction: {
                
                                   ／／这里是上拉加载的操作
                           })
        
                          }

这样就ok了。。。但你可能需要更多操作，比如：接收到数据并成功解析之后，关闭刷新动画，


step 5-1 : 关闭下拉刷新 ： myRefreshview?.endRefresh()


setp 5-2 ： 开启上拉刷新的功能，并进行上拉加载 ： 

self.myRefreshview?.refreshUpEnable = true ； 
myRefreshview?.beginRefreshFoot()

step 5-3 ; 结束上拉加载 ： self.myRefreshview?.endRefreshFoot()

