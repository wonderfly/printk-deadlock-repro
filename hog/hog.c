#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kthread.h>
 
MODULE_LICENSE("GPL");
 
static int
hog_thread(void *data)
{
    printk(KERN_INFO "Hogging a CPU now\n");
    while (1);
    return 0;
}
 
static int __init
hog_init(void)
{
    kthread_run(hog_thread, NULL, "hog");
    return 0;
}
 
module_init(hog_init);
