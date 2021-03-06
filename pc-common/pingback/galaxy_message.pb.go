// Code generated by protoc-gen-go. DO NOT EDIT.
// source: galaxy_message.proto

package galaxy_message

import (
	fmt "fmt"
	proto "github.com/golang/protobuf/proto"
	math "math"
)

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion3 // please upgrade the proto package

//日志来源
type LogEntry_Os int32

const (
	LogEntry_OS_DEFAULT LogEntry_Os = 0
	LogEntry_PC         LogEntry_Os = 1
	LogEntry_ANDROID    LogEntry_Os = 2
	LogEntry_IOS        LogEntry_Os = 3
	//H5
	LogEntry_WEB LogEntry_Os = 4
	//服务端、ERP
	LogEntry_SERVER  LogEntry_Os = 5
	LogEntry_BACKEND LogEntry_Os = 6
)

var LogEntry_Os_name = map[int32]string{
	0: "OS_DEFAULT",
	1: "PC",
	2: "ANDROID",
	3: "IOS",
	4: "WEB",
	5: "SERVER",
	6: "BACKEND",
}

var LogEntry_Os_value = map[string]int32{
	"OS_DEFAULT": 0,
	"PC":         1,
	"ANDROID":    2,
	"IOS":        3,
	"WEB":        4,
	"SERVER":     5,
	"BACKEND":    6,
}

func (x LogEntry_Os) String() string {
	return proto.EnumName(LogEntry_Os_name, int32(x))
}

func (LogEntry_Os) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 0}
}

//用户类型
type LogEntry_UserType int32

const (
	LogEntry_USERTYPE_DEFAULT LogEntry_UserType = 0
	LogEntry_STU              LogEntry_UserType = 1
	LogEntry_TEA              LogEntry_UserType = 2
	LogEntry_CC               LogEntry_UserType = 3
	LogEntry_CR               LogEntry_UserType = 4
	LogEntry_AUDIT            LogEntry_UserType = 5
)

var LogEntry_UserType_name = map[int32]string{
	0: "USERTYPE_DEFAULT",
	1: "STU",
	2: "TEA",
	3: "CC",
	4: "CR",
	5: "AUDIT",
}

var LogEntry_UserType_value = map[string]int32{
	"USERTYPE_DEFAULT": 0,
	"STU":              1,
	"TEA":              2,
	"CC":               3,
	"CR":               4,
	"AUDIT":            5,
}

func (x LogEntry_UserType) String() string {
	return proto.EnumName(LogEntry_UserType_name, int32(x))
}

func (LogEntry_UserType) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 1}
}

//日志类型
type LogEntry_LogType int32

const (
	LogEntry_LOGTYPE_DEFAULT LogEntry_LogType = 0
	LogEntry_CLICK           LogEntry_LogType = 1
	LogEntry_PV              LogEntry_LogType = 2
	LogEntry_HEARTBEAT       LogEntry_LogType = 3
	LogEntry_APP             LogEntry_LogType = 4
	LogEntry_REFRESH         LogEntry_LogType = 5
	LogEntry_SEARCH          LogEntry_LogType = 6
)

var LogEntry_LogType_name = map[int32]string{
	0: "LOGTYPE_DEFAULT",
	1: "CLICK",
	2: "PV",
	3: "HEARTBEAT",
	4: "APP",
	5: "REFRESH",
	6: "SEARCH",
}

var LogEntry_LogType_value = map[string]int32{
	"LOGTYPE_DEFAULT": 0,
	"CLICK":           1,
	"PV":              2,
	"HEARTBEAT":       3,
	"APP":             4,
	"REFRESH":         5,
	"SEARCH":          6,
}

func (x LogEntry_LogType) String() string {
	return proto.EnumName(LogEntry_LogType_name, int32(x))
}

func (LogEntry_LogType) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 2}
}

//网络类型
type LogEntry_NetType int32

const (
	LogEntry_NETTYPE_DEFAULT LogEntry_NetType = 0
	LogEntry_G2              LogEntry_NetType = 1
	LogEntry_G3              LogEntry_NetType = 2
	LogEntry_G4              LogEntry_NetType = 3
	LogEntry_G5              LogEntry_NetType = 4
	LogEntry_WIFI            LogEntry_NetType = 5
	//有线
	LogEntry_CABLE LogEntry_NetType = 6
	//未知
	LogEntry_NET_UNKNOW LogEntry_NetType = 7
)

var LogEntry_NetType_name = map[int32]string{
	0: "NETTYPE_DEFAULT",
	1: "G2",
	2: "G3",
	3: "G4",
	4: "G5",
	5: "WIFI",
	6: "CABLE",
	7: "NET_UNKNOW",
}

var LogEntry_NetType_value = map[string]int32{
	"NETTYPE_DEFAULT": 0,
	"G2":              1,
	"G3":              2,
	"G4":              3,
	"G5":              4,
	"WIFI":            5,
	"CABLE":           6,
	"NET_UNKNOW":      7,
}

func (x LogEntry_NetType) String() string {
	return proto.EnumName(LogEntry_NetType_name, int32(x))
}

func (LogEntry_NetType) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 3}
}

//APP相关 操作类型
type LogEntry_AppAction int32

const (
	LogEntry_APPACTION_DEFAULT LogEntry_AppAction = 0
	LogEntry_OPEN              LogEntry_AppAction = 1
	LogEntry_CRASH             LogEntry_AppAction = 2
	LogEntry_EXIT              LogEntry_AppAction = 3
)

var LogEntry_AppAction_name = map[int32]string{
	0: "APPACTION_DEFAULT",
	1: "OPEN",
	2: "CRASH",
	3: "EXIT",
}

var LogEntry_AppAction_value = map[string]int32{
	"APPACTION_DEFAULT": 0,
	"OPEN":              1,
	"CRASH":             2,
	"EXIT":              3,
}

func (x LogEntry_AppAction) String() string {
	return proto.EnumName(LogEntry_AppAction_name, int32(x))
}

func (LogEntry_AppAction) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 4}
}

type LogEntry_Company int32

const (
	LogEntry_COMPANY_DEFAULT LogEntry_Company = 0
	LogEntry_YIMI            LogEntry_Company = 1
	LogEntry_JUREN           LogEntry_Company = 2
)

var LogEntry_Company_name = map[int32]string{
	0: "COMPANY_DEFAULT",
	1: "YIMI",
	2: "JUREN",
}

var LogEntry_Company_value = map[string]int32{
	"COMPANY_DEFAULT": 0,
	"YIMI":            1,
	"JUREN":           2,
}

func (x LogEntry_Company) String() string {
	return proto.EnumName(LogEntry_Company_name, int32(x))
}

func (LogEntry_Company) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 5}
}

type LogEntry_OperatorType int32

const (
	LogEntry_OPERATORTYPE_DEFAULT LogEntry_OperatorType = 0
	//联通
	LogEntry_UNICOM LogEntry_OperatorType = 1
	//电信
	LogEntry_TELECOM LogEntry_OperatorType = 2
	//移动
	LogEntry_MOBILE          LogEntry_OperatorType = 3
	LogEntry_OPERATOR_UNKNOW LogEntry_OperatorType = 4
)

var LogEntry_OperatorType_name = map[int32]string{
	0: "OPERATORTYPE_DEFAULT",
	1: "UNICOM",
	2: "TELECOM",
	3: "MOBILE",
	4: "OPERATOR_UNKNOW",
}

var LogEntry_OperatorType_value = map[string]int32{
	"OPERATORTYPE_DEFAULT": 0,
	"UNICOM":               1,
	"TELECOM":              2,
	"MOBILE":               3,
	"OPERATOR_UNKNOW":      4,
}

func (x LogEntry_OperatorType) String() string {
	return proto.EnumName(LogEntry_OperatorType_name, int32(x))
}

func (LogEntry_OperatorType) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 6}
}

//课程类型
type LogEntry_LessonType int32

const (
	LogEntry_LESSONTYPE_DEFAULT LogEntry_LessonType = 0
	//试听课
	LogEntry_AUDITION LogEntry_LessonType = 1
	//正常课
	LogEntry_ORDER LogEntry_LessonType = 2
	// 标准试听课
	LogEntry_AUDITION_U LogEntry_LessonType = 3
	// 普通试听课
	LogEntry_AUDITION_N LogEntry_LessonType = 4
)

var LogEntry_LessonType_name = map[int32]string{
	0: "LESSONTYPE_DEFAULT",
	1: "AUDITION",
	2: "ORDER",
	3: "AUDITION_U",
	4: "AUDITION_N",
}

var LogEntry_LessonType_value = map[string]int32{
	"LESSONTYPE_DEFAULT": 0,
	"AUDITION":           1,
	"ORDER":              2,
	"AUDITION_U":         3,
	"AUDITION_N":         4,
}

func (x LogEntry_LessonType) String() string {
	return proto.EnumName(LogEntry_LessonType_name, int32(x))
}

func (LogEntry_LessonType) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 7}
}

//版本类型
type LogEntry_SDKVersion int32

const (
	LogEntry_SDKVERSION_DEFAULT LogEntry_SDKVersion = 0
	LogEntry_V100               LogEntry_SDKVersion = 1
	LogEntry_V101               LogEntry_SDKVersion = 2
	LogEntry_V102               LogEntry_SDKVersion = 3
	LogEntry_V103               LogEntry_SDKVersion = 4
	LogEntry_V104               LogEntry_SDKVersion = 5
	LogEntry_V105               LogEntry_SDKVersion = 6
	LogEntry_V106               LogEntry_SDKVersion = 7
	LogEntry_V107               LogEntry_SDKVersion = 8
	LogEntry_V108               LogEntry_SDKVersion = 9
	LogEntry_V109               LogEntry_SDKVersion = 10
	LogEntry_V110               LogEntry_SDKVersion = 11
	LogEntry_V111               LogEntry_SDKVersion = 12
	LogEntry_V112               LogEntry_SDKVersion = 13
	LogEntry_V113               LogEntry_SDKVersion = 14
	LogEntry_V114               LogEntry_SDKVersion = 15
	LogEntry_V115               LogEntry_SDKVersion = 16
	LogEntry_V116               LogEntry_SDKVersion = 17
	LogEntry_V117               LogEntry_SDKVersion = 18
	LogEntry_V118               LogEntry_SDKVersion = 19
	LogEntry_V119               LogEntry_SDKVersion = 20
	LogEntry_V120               LogEntry_SDKVersion = 21
	LogEntry_V121               LogEntry_SDKVersion = 22
	LogEntry_V122               LogEntry_SDKVersion = 23
	LogEntry_V123               LogEntry_SDKVersion = 24
	LogEntry_V124               LogEntry_SDKVersion = 25
	LogEntry_V125               LogEntry_SDKVersion = 26
	LogEntry_V126               LogEntry_SDKVersion = 27
	LogEntry_V127               LogEntry_SDKVersion = 28
	LogEntry_V128               LogEntry_SDKVersion = 29
	LogEntry_V129               LogEntry_SDKVersion = 30
	LogEntry_V130               LogEntry_SDKVersion = 31
)

var LogEntry_SDKVersion_name = map[int32]string{
	0:  "SDKVERSION_DEFAULT",
	1:  "V100",
	2:  "V101",
	3:  "V102",
	4:  "V103",
	5:  "V104",
	6:  "V105",
	7:  "V106",
	8:  "V107",
	9:  "V108",
	10: "V109",
	11: "V110",
	12: "V111",
	13: "V112",
	14: "V113",
	15: "V114",
	16: "V115",
	17: "V116",
	18: "V117",
	19: "V118",
	20: "V119",
	21: "V120",
	22: "V121",
	23: "V122",
	24: "V123",
	25: "V124",
	26: "V125",
	27: "V126",
	28: "V127",
	29: "V128",
	30: "V129",
	31: "V130",
}

var LogEntry_SDKVersion_value = map[string]int32{
	"SDKVERSION_DEFAULT": 0,
	"V100":               1,
	"V101":               2,
	"V102":               3,
	"V103":               4,
	"V104":               5,
	"V105":               6,
	"V106":               7,
	"V107":               8,
	"V108":               9,
	"V109":               10,
	"V110":               11,
	"V111":               12,
	"V112":               13,
	"V113":               14,
	"V114":               15,
	"V115":               16,
	"V116":               17,
	"V117":               18,
	"V118":               19,
	"V119":               20,
	"V120":               21,
	"V121":               22,
	"V122":               23,
	"V123":               24,
	"V124":               25,
	"V125":               26,
	"V126":               27,
	"V127":               28,
	"V128":               29,
	"V129":               30,
	"V130":               31,
}

func (x LogEntry_SDKVersion) String() string {
	return proto.EnumName(LogEntry_SDKVersion_name, int32(x))
}

func (LogEntry_SDKVersion) EnumDescriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 8}
}

// [START messages]
type LogEntry struct {
	BaseInfo             *LogEntry_BaseInfo    `protobuf:"bytes,1,opt,name=baseInfo,proto3" json:"baseInfo,omitempty"`
	LiveInfo             *LogEntry_LiveInfo    `protobuf:"bytes,2,opt,name=liveInfo,proto3" json:"liveInfo,omitempty"`
	ExtraInfo            []*LogEntry_ExtraInfo `protobuf:"bytes,3,rep,name=extraInfo,proto3" json:"extraInfo,omitempty"`
	XXX_NoUnkeyedLiteral struct{}              `json:"-"`
	XXX_unrecognized     []byte                `json:"-"`
	XXX_sizecache        int32                 `json:"-"`
}

func (m *LogEntry) Reset()         { *m = LogEntry{} }
func (m *LogEntry) String() string { return proto.CompactTextString(m) }
func (*LogEntry) ProtoMessage()    {}
func (*LogEntry) Descriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0}
}

func (m *LogEntry) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_LogEntry.Unmarshal(m, b)
}
func (m *LogEntry) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_LogEntry.Marshal(b, m, deterministic)
}
func (m *LogEntry) XXX_Merge(src proto.Message) {
	xxx_messageInfo_LogEntry.Merge(m, src)
}
func (m *LogEntry) XXX_Size() int {
	return xxx_messageInfo_LogEntry.Size(m)
}
func (m *LogEntry) XXX_DiscardUnknown() {
	xxx_messageInfo_LogEntry.DiscardUnknown(m)
}

var xxx_messageInfo_LogEntry proto.InternalMessageInfo

func (m *LogEntry) GetBaseInfo() *LogEntry_BaseInfo {
	if m != nil {
		return m.BaseInfo
	}
	return nil
}

func (m *LogEntry) GetLiveInfo() *LogEntry_LiveInfo {
	if m != nil {
		return m.LiveInfo
	}
	return nil
}

func (m *LogEntry) GetExtraInfo() []*LogEntry_ExtraInfo {
	if m != nil {
		return m.ExtraInfo
	}
	return nil
}

//每次请求时上报的基本信息
type LogEntry_BaseInfo struct {
	//系统上报时间戳-毫秒(由银河服务端生成)
	SysTime int64 `protobuf:"varint,1,opt,name=sysTime,proto3" json:"sysTime,omitempty"`
	//客户端上报时间戳-毫秒
	Time int64 `protobuf:"varint,2,opt,name=time,proto3" json:"time,omitempty"`
	//会话Id，一段会话的唯一标识（客户端每次启动APP到下一次启动APP之间生成一个会话id）
	//生成规则：16位随机数+13位时间戳+3位(端表示pc:001 android:002 ios:003 web:004 server:005)
	SessionId string `protobuf:"bytes,3,opt,name=sessionId,proto3" json:"sessionId,omitempty"`
	//设备唯一标识
	Uuid string `protobuf:"bytes,4,opt,name=uuid,proto3" json:"uuid,omitempty"`
	//公司标识
	Company LogEntry_Company `protobuf:"varint,5,opt,name=company,proto3,enum=LogEntry_Company" json:"company,omitempty"`
	//sdk版本
	SdkVersion LogEntry_SDKVersion `protobuf:"varint,6,opt,name=sdkVersion,proto3,enum=LogEntry_SDKVersion" json:"sdkVersion,omitempty"`
	//用户ID
	UserId string `protobuf:"bytes,7,opt,name=userId,proto3" json:"userId,omitempty"`
	//用户类型
	UserType LogEntry_UserType `protobuf:"varint,8,opt,name=userType,proto3,enum=LogEntry_UserType" json:"userType,omitempty"`
	//日志类型
	Type         LogEntry_LogType      `protobuf:"varint,9,opt,name=type,proto3,enum=LogEntry_LogType" json:"type,omitempty"`
	EventId      string                `protobuf:"bytes,10,opt,name=eventId,proto3" json:"eventId,omitempty"`
	NetType      LogEntry_NetType      `protobuf:"varint,11,opt,name=netType,proto3,enum=LogEntry_NetType" json:"netType,omitempty"`
	OperatorType LogEntry_OperatorType `protobuf:"varint,12,opt,name=operatorType,proto3,enum=LogEntry_OperatorType" json:"operatorType,omitempty"`
	RequestCnt   int32                 `protobuf:"varint,13,opt,name=requestCnt,proto3" json:"requestCnt,omitempty"`
	Business     string                `protobuf:"bytes,14,opt,name=business,proto3" json:"business,omitempty"`
	//来源:安卓、iOS、pc、web、server
	Os      LogEntry_Os `protobuf:"varint,15,opt,name=os,proto3,enum=LogEntry_Os" json:"os,omitempty"`
	Channel string      `protobuf:"bytes,16,opt,name=channel,proto3" json:"channel,omitempty"`
	//APP版本号
	AppVersion string `protobuf:"bytes,17,opt,name=appVersion,proto3" json:"appVersion,omitempty"`
	//APP类型：yimi/bubugao/yuxuepai
	AppType string `protobuf:"bytes,18,opt,name=appType,proto3" json:"appType,omitempty"`
	//设备型号，标示手机品牌+型号
	DeviceInfo string `protobuf:"bytes,19,opt,name=deviceInfo,proto3" json:"deviceInfo,omitempty"`
	//设备操作系统版本号
	OsVersion string             `protobuf:"bytes,20,opt,name=osVersion,proto3" json:"osVersion,omitempty"`
	AppAction LogEntry_AppAction `protobuf:"varint,21,opt,name=appAction,proto3,enum=LogEntry_AppAction" json:"appAction,omitempty"`
	//信息,崩溃信息
	Info                 string   `protobuf:"bytes,22,opt,name=info,proto3" json:"info,omitempty"`
	StayTime             int64    `protobuf:"varint,23,opt,name=stayTime,proto3" json:"stayTime,omitempty"`
	XXX_NoUnkeyedLiteral struct{} `json:"-"`
	XXX_unrecognized     []byte   `json:"-"`
	XXX_sizecache        int32    `json:"-"`
}

func (m *LogEntry_BaseInfo) Reset()         { *m = LogEntry_BaseInfo{} }
func (m *LogEntry_BaseInfo) String() string { return proto.CompactTextString(m) }
func (*LogEntry_BaseInfo) ProtoMessage()    {}
func (*LogEntry_BaseInfo) Descriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 0}
}

func (m *LogEntry_BaseInfo) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_LogEntry_BaseInfo.Unmarshal(m, b)
}
func (m *LogEntry_BaseInfo) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_LogEntry_BaseInfo.Marshal(b, m, deterministic)
}
func (m *LogEntry_BaseInfo) XXX_Merge(src proto.Message) {
	xxx_messageInfo_LogEntry_BaseInfo.Merge(m, src)
}
func (m *LogEntry_BaseInfo) XXX_Size() int {
	return xxx_messageInfo_LogEntry_BaseInfo.Size(m)
}
func (m *LogEntry_BaseInfo) XXX_DiscardUnknown() {
	xxx_messageInfo_LogEntry_BaseInfo.DiscardUnknown(m)
}

var xxx_messageInfo_LogEntry_BaseInfo proto.InternalMessageInfo

func (m *LogEntry_BaseInfo) GetSysTime() int64 {
	if m != nil {
		return m.SysTime
	}
	return 0
}

func (m *LogEntry_BaseInfo) GetTime() int64 {
	if m != nil {
		return m.Time
	}
	return 0
}

func (m *LogEntry_BaseInfo) GetSessionId() string {
	if m != nil {
		return m.SessionId
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetUuid() string {
	if m != nil {
		return m.Uuid
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetCompany() LogEntry_Company {
	if m != nil {
		return m.Company
	}
	return LogEntry_COMPANY_DEFAULT
}

func (m *LogEntry_BaseInfo) GetSdkVersion() LogEntry_SDKVersion {
	if m != nil {
		return m.SdkVersion
	}
	return LogEntry_SDKVERSION_DEFAULT
}

func (m *LogEntry_BaseInfo) GetUserId() string {
	if m != nil {
		return m.UserId
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetUserType() LogEntry_UserType {
	if m != nil {
		return m.UserType
	}
	return LogEntry_USERTYPE_DEFAULT
}

func (m *LogEntry_BaseInfo) GetType() LogEntry_LogType {
	if m != nil {
		return m.Type
	}
	return LogEntry_LOGTYPE_DEFAULT
}

func (m *LogEntry_BaseInfo) GetEventId() string {
	if m != nil {
		return m.EventId
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetNetType() LogEntry_NetType {
	if m != nil {
		return m.NetType
	}
	return LogEntry_NETTYPE_DEFAULT
}

func (m *LogEntry_BaseInfo) GetOperatorType() LogEntry_OperatorType {
	if m != nil {
		return m.OperatorType
	}
	return LogEntry_OPERATORTYPE_DEFAULT
}

func (m *LogEntry_BaseInfo) GetRequestCnt() int32 {
	if m != nil {
		return m.RequestCnt
	}
	return 0
}

func (m *LogEntry_BaseInfo) GetBusiness() string {
	if m != nil {
		return m.Business
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetOs() LogEntry_Os {
	if m != nil {
		return m.Os
	}
	return LogEntry_OS_DEFAULT
}

func (m *LogEntry_BaseInfo) GetChannel() string {
	if m != nil {
		return m.Channel
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetAppVersion() string {
	if m != nil {
		return m.AppVersion
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetAppType() string {
	if m != nil {
		return m.AppType
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetDeviceInfo() string {
	if m != nil {
		return m.DeviceInfo
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetOsVersion() string {
	if m != nil {
		return m.OsVersion
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetAppAction() LogEntry_AppAction {
	if m != nil {
		return m.AppAction
	}
	return LogEntry_APPACTION_DEFAULT
}

func (m *LogEntry_BaseInfo) GetInfo() string {
	if m != nil {
		return m.Info
	}
	return ""
}

func (m *LogEntry_BaseInfo) GetStayTime() int64 {
	if m != nil {
		return m.StayTime
	}
	return 0
}

//heartbeat，教室内事件上报
type LogEntry_LiveInfo struct {
	//课程id
	LessonId string `protobuf:"bytes,1,opt,name=lessonId,proto3" json:"lessonId,omitempty"`
	//课程类型
	LessonType LogEntry_LessonType `protobuf:"varint,2,opt,name=lessonType,proto3,enum=LogEntry_LessonType" json:"lessonType,omitempty"`
	//服务器IP
	ServerIp string `protobuf:"bytes,3,opt,name=serverIp,proto3" json:"serverIp,omitempty"`
	//用户ip
	UserIp               string   `protobuf:"bytes,4,opt,name=userIp,proto3" json:"userIp,omitempty"`
	XXX_NoUnkeyedLiteral struct{} `json:"-"`
	XXX_unrecognized     []byte   `json:"-"`
	XXX_sizecache        int32    `json:"-"`
}

func (m *LogEntry_LiveInfo) Reset()         { *m = LogEntry_LiveInfo{} }
func (m *LogEntry_LiveInfo) String() string { return proto.CompactTextString(m) }
func (*LogEntry_LiveInfo) ProtoMessage()    {}
func (*LogEntry_LiveInfo) Descriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 1}
}

func (m *LogEntry_LiveInfo) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_LogEntry_LiveInfo.Unmarshal(m, b)
}
func (m *LogEntry_LiveInfo) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_LogEntry_LiveInfo.Marshal(b, m, deterministic)
}
func (m *LogEntry_LiveInfo) XXX_Merge(src proto.Message) {
	xxx_messageInfo_LogEntry_LiveInfo.Merge(m, src)
}
func (m *LogEntry_LiveInfo) XXX_Size() int {
	return xxx_messageInfo_LogEntry_LiveInfo.Size(m)
}
func (m *LogEntry_LiveInfo) XXX_DiscardUnknown() {
	xxx_messageInfo_LogEntry_LiveInfo.DiscardUnknown(m)
}

var xxx_messageInfo_LogEntry_LiveInfo proto.InternalMessageInfo

func (m *LogEntry_LiveInfo) GetLessonId() string {
	if m != nil {
		return m.LessonId
	}
	return ""
}

func (m *LogEntry_LiveInfo) GetLessonType() LogEntry_LessonType {
	if m != nil {
		return m.LessonType
	}
	return LogEntry_LESSONTYPE_DEFAULT
}

func (m *LogEntry_LiveInfo) GetServerIp() string {
	if m != nil {
		return m.ServerIp
	}
	return ""
}

func (m *LogEntry_LiveInfo) GetUserIp() string {
	if m != nil {
		return m.UserIp
	}
	return ""
}

//额外key、value上报
type LogEntry_ExtraInfo struct {
	//额外字段key
	Key string `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	//额外字段value
	Value                string   `protobuf:"bytes,2,opt,name=value,proto3" json:"value,omitempty"`
	XXX_NoUnkeyedLiteral struct{} `json:"-"`
	XXX_unrecognized     []byte   `json:"-"`
	XXX_sizecache        int32    `json:"-"`
}

func (m *LogEntry_ExtraInfo) Reset()         { *m = LogEntry_ExtraInfo{} }
func (m *LogEntry_ExtraInfo) String() string { return proto.CompactTextString(m) }
func (*LogEntry_ExtraInfo) ProtoMessage()    {}
func (*LogEntry_ExtraInfo) Descriptor() ([]byte, []int) {
	return fileDescriptor_dc63d524f077cdf9, []int{0, 2}
}

func (m *LogEntry_ExtraInfo) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_LogEntry_ExtraInfo.Unmarshal(m, b)
}
func (m *LogEntry_ExtraInfo) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_LogEntry_ExtraInfo.Marshal(b, m, deterministic)
}
func (m *LogEntry_ExtraInfo) XXX_Merge(src proto.Message) {
	xxx_messageInfo_LogEntry_ExtraInfo.Merge(m, src)
}
func (m *LogEntry_ExtraInfo) XXX_Size() int {
	return xxx_messageInfo_LogEntry_ExtraInfo.Size(m)
}
func (m *LogEntry_ExtraInfo) XXX_DiscardUnknown() {
	xxx_messageInfo_LogEntry_ExtraInfo.DiscardUnknown(m)
}

var xxx_messageInfo_LogEntry_ExtraInfo proto.InternalMessageInfo

func (m *LogEntry_ExtraInfo) GetKey() string {
	if m != nil {
		return m.Key
	}
	return ""
}

func (m *LogEntry_ExtraInfo) GetValue() string {
	if m != nil {
		return m.Value
	}
	return ""
}

func init() {
	proto.RegisterEnum("LogEntry_Os", LogEntry_Os_name, LogEntry_Os_value)
	proto.RegisterEnum("LogEntry_UserType", LogEntry_UserType_name, LogEntry_UserType_value)
	proto.RegisterEnum("LogEntry_LogType", LogEntry_LogType_name, LogEntry_LogType_value)
	proto.RegisterEnum("LogEntry_NetType", LogEntry_NetType_name, LogEntry_NetType_value)
	proto.RegisterEnum("LogEntry_AppAction", LogEntry_AppAction_name, LogEntry_AppAction_value)
	proto.RegisterEnum("LogEntry_Company", LogEntry_Company_name, LogEntry_Company_value)
	proto.RegisterEnum("LogEntry_OperatorType", LogEntry_OperatorType_name, LogEntry_OperatorType_value)
	proto.RegisterEnum("LogEntry_LessonType", LogEntry_LessonType_name, LogEntry_LessonType_value)
	proto.RegisterEnum("LogEntry_SDKVersion", LogEntry_SDKVersion_name, LogEntry_SDKVersion_value)
	proto.RegisterType((*LogEntry)(nil), "LogEntry")
	proto.RegisterType((*LogEntry_BaseInfo)(nil), "LogEntry.BaseInfo")
	proto.RegisterType((*LogEntry_LiveInfo)(nil), "LogEntry.LiveInfo")
	proto.RegisterType((*LogEntry_ExtraInfo)(nil), "LogEntry.ExtraInfo")
}

func init() { proto.RegisterFile("galaxy_message.proto", fileDescriptor_dc63d524f077cdf9) }

var fileDescriptor_dc63d524f077cdf9 = []byte{
	// 1107 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x64, 0x96, 0x6d, 0x6f, 0xe2, 0x46,
	0x10, 0xc7, 0x6b, 0x1b, 0x0c, 0x4c, 0x48, 0x32, 0xd9, 0x70, 0x39, 0x37, 0xbd, 0x5e, 0x23, 0xa4,
	0x4a, 0x91, 0x2a, 0x45, 0x3c, 0x24, 0xf7, 0xd0, 0x77, 0xc6, 0xec, 0x11, 0x37, 0x60, 0xa3, 0xc5,
	0x70, 0xbd, 0x17, 0x55, 0xe4, 0x04, 0x37, 0x45, 0x97, 0xc3, 0x2e, 0x36, 0xd1, 0xf1, 0x25, 0xaa,
	0x7e, 0xbe, 0x7e, 0x96, 0xbe, 0xa8, 0xf6, 0xc1, 0x40, 0xe8, 0x2b, 0x7e, 0xb3, 0xf3, 0x9f, 0x9d,
	0xd9, 0xd9, 0x59, 0x64, 0xa8, 0x3d, 0x84, 0x8f, 0xe1, 0xd7, 0xd5, 0xed, 0x97, 0x28, 0x4d, 0xc3,
	0x87, 0xe8, 0x22, 0x59, 0xc4, 0x59, 0x5c, 0xff, 0x17, 0xa1, 0xdc, 0x8f, 0x1f, 0xe8, 0x3c, 0x5b,
	0xac, 0xc8, 0x05, 0x94, 0xef, 0xc2, 0x34, 0x72, 0xe7, 0xbf, 0xc7, 0x96, 0x76, 0xa6, 0x9d, 0xef,
	0xb5, 0xc8, 0x45, 0xee, 0xbc, 0xe8, 0x28, 0x0f, 0x5b, 0x6b, 0xb8, 0xfe, 0x71, 0xf6, 0x24, 0xf5,
	0xfa, 0xae, 0xbe, 0xaf, 0x3c, 0x6c, 0xad, 0x21, 0x4d, 0xa8, 0x44, 0x5f, 0xb3, 0x45, 0x28, 0x02,
	0x8c, 0x33, 0xe3, 0x7c, 0xaf, 0x75, 0xbc, 0x09, 0xa0, 0xb9, 0x8b, 0x6d, 0x54, 0xa7, 0x7f, 0x99,
	0x50, 0xce, 0x33, 0x13, 0x0b, 0x4a, 0xe9, 0x2a, 0x0d, 0x66, 0x5f, 0x22, 0x51, 0x9e, 0xc1, 0x72,
	0x93, 0x10, 0x28, 0x64, 0x7c, 0x59, 0x17, 0xcb, 0x82, 0xc9, 0x2b, 0xa8, 0xa4, 0x51, 0x9a, 0xce,
	0xe2, 0xb9, 0x3b, 0xb5, 0x8c, 0x33, 0xed, 0xbc, 0xc2, 0x36, 0x0b, 0x3c, 0x62, 0xb9, 0x9c, 0x4d,
	0xad, 0x82, 0x70, 0x08, 0x26, 0x3f, 0x41, 0xe9, 0x3e, 0xfe, 0x92, 0x84, 0xf3, 0x95, 0x55, 0x3c,
	0xd3, 0xce, 0x0f, 0x5a, 0x47, 0x9b, 0xea, 0x1c, 0xe9, 0x60, 0xb9, 0x82, 0x5c, 0x02, 0xa4, 0xd3,
	0xcf, 0x93, 0x68, 0xc1, 0x37, 0xb4, 0x4c, 0xa1, 0xaf, 0x6d, 0xf4, 0xa3, 0xee, 0x8d, 0xf2, 0xb1,
	0x2d, 0x1d, 0x39, 0x01, 0x73, 0x99, 0x46, 0x0b, 0x77, 0x6a, 0x95, 0x44, 0x62, 0x65, 0xf1, 0x56,
	0x72, 0x0a, 0x56, 0x49, 0x64, 0x95, 0xc5, 0x5e, 0x5b, 0xad, 0x1c, 0x2b, 0x0f, 0x5b, 0x6b, 0xc8,
	0x8f, 0x50, 0xc8, 0xb8, 0xb6, 0xb2, 0x5b, 0x67, 0x3f, 0x7e, 0x10, 0x52, 0xe1, 0xe6, 0x1d, 0x8b,
	0x9e, 0xa2, 0x79, 0xe6, 0x4e, 0x2d, 0x10, 0xf9, 0x72, 0x93, 0x9f, 0x75, 0x1e, 0x65, 0x22, 0xdf,
	0xde, 0xee, 0x1e, 0x9e, 0x74, 0xb0, 0x5c, 0x41, 0x7e, 0x86, 0x6a, 0x9c, 0x44, 0x8b, 0x30, 0x8b,
	0x65, 0x85, 0x55, 0x11, 0x71, 0xb2, 0x89, 0xf0, 0xb7, 0xbc, 0xec, 0x99, 0x96, 0xbc, 0x06, 0x58,
	0x44, 0x7f, 0x2e, 0xa3, 0x34, 0x73, 0xe6, 0x99, 0xb5, 0x7f, 0xa6, 0x9d, 0x17, 0xd9, 0xd6, 0x0a,
	0x39, 0x85, 0xf2, 0xdd, 0x32, 0x9d, 0xcd, 0xa3, 0x34, 0xb5, 0x0e, 0x44, 0x8d, 0x6b, 0x9b, 0xbc,
	0x02, 0x3d, 0x4e, 0xad, 0x43, 0x91, 0xad, 0xba, 0x95, 0x2d, 0x65, 0x7a, 0x9c, 0xf2, 0xc3, 0xdd,
	0xff, 0x11, 0xce, 0xe7, 0xd1, 0xa3, 0x85, 0xf2, 0x70, 0xca, 0xe4, 0x39, 0xc3, 0x24, 0xc9, 0xef,
	0xe6, 0x48, 0x38, 0xb7, 0x56, 0x78, 0x64, 0x98, 0x24, 0xe2, 0x28, 0x44, 0x46, 0x2a, 0x93, 0x47,
	0x4e, 0xa3, 0xa7, 0xd9, 0xbd, 0x1c, 0xea, 0x63, 0x19, 0xb9, 0x59, 0xe1, 0x43, 0x15, 0xa7, 0xf9,
	0xc6, 0x35, 0x39, 0x54, 0xeb, 0x05, 0x3e, 0xe0, 0x61, 0x92, 0xd8, 0xf7, 0x19, 0xf7, 0xbe, 0x10,
	0x65, 0x6f, 0x0d, 0xb8, 0x9d, 0xbb, 0xd8, 0x46, 0xc5, 0xe7, 0x70, 0xc6, 0x53, 0x9d, 0xc8, 0x39,
	0xe4, 0xcc, 0x5b, 0x92, 0x66, 0xe1, 0x4a, 0x0c, 0xfa, 0x4b, 0x31, 0xd1, 0x6b, 0xfb, 0xf4, 0x6f,
	0x0d, 0xca, 0xf9, 0xd3, 0xe2, 0xc2, 0xc7, 0x28, 0x4d, 0xc5, 0x84, 0x6b, 0xb2, 0x77, 0xb9, 0xcd,
	0xe7, 0x53, 0xb2, 0x38, 0xa6, 0xbe, 0x3b, 0x9f, 0xfd, 0xb5, 0x8f, 0x6d, 0xe9, 0x44, 0xea, 0x68,
	0xf1, 0x14, 0x2d, 0xdc, 0x44, 0xbd, 0x99, 0xb5, 0xbd, 0x9e, 0xdd, 0x44, 0x3d, 0x1a, 0x65, 0x9d,
	0xb6, 0xa1, 0xb2, 0x7e, 0xbb, 0x04, 0xc1, 0xf8, 0x1c, 0xad, 0x54, 0x35, 0x1c, 0x49, 0x0d, 0x8a,
	0x4f, 0xe1, 0xe3, 0x52, 0xd6, 0x50, 0x61, 0xd2, 0xa8, 0x07, 0xa0, 0xfb, 0x29, 0x39, 0x00, 0xf0,
	0x47, 0xb7, 0x5d, 0xfa, 0xc1, 0x1e, 0xf7, 0x03, 0xfc, 0x86, 0x98, 0xa0, 0x0f, 0x1d, 0xd4, 0xc8,
	0x1e, 0x94, 0x6c, 0xaf, 0xcb, 0x7c, 0xb7, 0x8b, 0x3a, 0x29, 0x81, 0xe1, 0xfa, 0x23, 0x34, 0x38,
	0x7c, 0xa4, 0x1d, 0x2c, 0x10, 0x00, 0x73, 0x44, 0xd9, 0x84, 0x32, 0x2c, 0x72, 0x69, 0xc7, 0x76,
	0x6e, 0xa8, 0xd7, 0x45, 0xb3, 0x3e, 0x80, 0x72, 0xfe, 0x58, 0x48, 0x0d, 0x70, 0x3c, 0xa2, 0x2c,
	0xf8, 0x34, 0xa4, 0x5b, 0x19, 0x4a, 0x60, 0x8c, 0x82, 0x31, 0x6a, 0x1c, 0x02, 0x6a, 0xa3, 0xce,
	0x73, 0x3a, 0x0e, 0x1a, 0xe2, 0x97, 0x61, 0x81, 0x54, 0xa0, 0x68, 0x8f, 0xbb, 0x6e, 0x80, 0xc5,
	0xfa, 0x1d, 0x94, 0xd4, 0x7b, 0x22, 0xc7, 0x70, 0xd8, 0xf7, 0x7b, 0x3b, 0x9b, 0x55, 0xa0, 0xe8,
	0xf4, 0x5d, 0xe7, 0x06, 0x35, 0x51, 0xf9, 0x04, 0x75, 0xb2, 0x0f, 0x95, 0x6b, 0x6a, 0xb3, 0xa0,
	0x43, 0xed, 0x40, 0x96, 0x6c, 0x0f, 0x87, 0x58, 0xe0, 0x65, 0x32, 0xfa, 0x81, 0xd1, 0xd1, 0x35,
	0x16, 0x65, 0xfd, 0x36, 0x73, 0xae, 0xd1, 0xac, 0xdf, 0x43, 0x49, 0xbd, 0x37, 0x9e, 0xc3, 0xa3,
	0xc1, 0x4e, 0x0e, 0x13, 0xf4, 0x5e, 0x4b, 0x26, 0xe8, 0xb5, 0x65, 0xb9, 0xbd, 0x4b, 0x59, 0x6e,
	0xef, 0x0a, 0x0b, 0xa4, 0x0c, 0x85, 0x8f, 0xee, 0x07, 0x17, 0x8b, 0xa2, 0x1a, 0xbb, 0xd3, 0xa7,
	0x68, 0xf2, 0xbe, 0x7a, 0x34, 0xb8, 0x1d, 0x7b, 0x37, 0x9e, 0xff, 0x11, 0x4b, 0x75, 0x1b, 0x2a,
	0xeb, 0xe9, 0x23, 0x2f, 0xe0, 0xc8, 0x1e, 0x0e, 0x6d, 0x27, 0x70, 0x7d, 0x6f, 0x2b, 0x51, 0x19,
	0x0a, 0xfe, 0x90, 0x7a, 0xa8, 0x89, 0x8d, 0x98, 0x3d, 0xba, 0x46, 0x9d, 0x2f, 0xd2, 0x5f, 0xdd,
	0x00, 0x8d, 0x7a, 0x1b, 0x4a, 0xea, 0x3f, 0x90, 0xd7, 0xe9, 0xf8, 0x83, 0xa1, 0xed, 0x7d, 0x7a,
	0x1e, 0xfe, 0xc9, 0x1d, 0xb8, 0x32, 0xfc, 0x97, 0x31, 0xa3, 0x1e, 0xea, 0xf5, 0x3b, 0xa8, 0x6e,
	0xff, 0x35, 0x10, 0x0b, 0x6a, 0xfe, 0x90, 0x32, 0x3b, 0xf0, 0x77, 0xef, 0x05, 0xc0, 0x1c, 0x7b,
	0xae, 0xe3, 0x0f, 0xe4, 0xed, 0x07, 0xb4, 0x4f, 0xb9, 0xa1, 0x73, 0xc7, 0xc0, 0xef, 0xb8, 0x7d,
	0x8a, 0x06, 0x4f, 0x9c, 0x87, 0xe7, 0x67, 0x2b, 0xd4, 0x7f, 0x03, 0xd8, 0x0c, 0x33, 0x39, 0x01,
	0xd2, 0xa7, 0xa3, 0x91, 0xef, 0xed, 0xec, 0x5f, 0x85, 0xb2, 0xb8, 0x55, 0xd7, 0x57, 0x27, 0xf4,
	0x59, 0x97, 0x32, 0xd4, 0x79, 0xab, 0x72, 0xc7, 0xed, 0x18, 0x8d, 0x67, 0xb6, 0x87, 0x85, 0xfa,
	0x3f, 0x3a, 0xc0, 0xe6, 0xcf, 0x9c, 0xef, 0xcf, 0x2d, 0xca, 0x46, 0xff, 0xeb, 0xde, 0xa4, 0xd9,
	0x68, 0xa0, 0xa6, 0xa8, 0x29, 0x9b, 0x37, 0x69, 0x36, 0x5a, 0x68, 0x28, 0x6a, 0xcb, 0xeb, 0x9a,
	0x34, 0x1b, 0x97, 0x58, 0x54, 0x74, 0x85, 0xa6, 0xa2, 0x37, 0x58, 0x52, 0xf4, 0x16, 0xcb, 0x8a,
	0xde, 0x61, 0x45, 0xd1, 0x7b, 0x04, 0x49, 0xcd, 0x06, 0xee, 0x29, 0x6a, 0x62, 0x55, 0x51, 0x0b,
	0xf7, 0x15, 0xb5, 0xf1, 0x40, 0xd1, 0x25, 0x1e, 0x2a, 0xba, 0x42, 0x54, 0xf4, 0x06, 0x8f, 0x14,
	0xbd, 0x45, 0xa2, 0xe8, 0x1d, 0x1e, 0x2b, 0x7a, 0x8f, 0x35, 0x49, 0xad, 0x06, 0xbe, 0x50, 0xd4,
	0xc4, 0x13, 0x45, 0x2d, 0x7c, 0xa9, 0xa8, 0x8d, 0x96, 0xa2, 0x4b, 0xfc, 0x56, 0xd1, 0x15, 0x9e,
	0x2a, 0x7a, 0x83, 0xdf, 0x29, 0x7a, 0x8b, 0xaf, 0x14, 0xbd, 0xc3, 0xef, 0x15, 0xbd, 0xc7, 0xd7,
	0x92, 0xda, 0x0d, 0xfc, 0xa1, 0x73, 0xd8, 0xd9, 0xef, 0x89, 0xcf, 0x92, 0x81, 0xfc, 0x2a, 0xb9,
	0x33, 0xc5, 0x67, 0x49, 0xfb, 0xbf, 0x00, 0x00, 0x00, 0xff, 0xff, 0x78, 0x9c, 0xe3, 0x1d, 0xae,
	0x08, 0x00, 0x00,
}
