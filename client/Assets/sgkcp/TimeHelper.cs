using System;

namespace SG
{
#if SLUA
	[SLua.CustomLuaClass]
#endif
	public static class TimeHelper
    {
        private static readonly DateTime utc_time = new DateTime(1970, 1, 1);
        public static uint GetMilliseconds()
		{
			return (uint)(Convert.ToInt64(DateTime.UtcNow.Subtract(utc_time).TotalMilliseconds) & 0xffffffff);
		}
	}
}
