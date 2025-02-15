# Host: localhost  (Version: 5.7.44)
# Date: 2025-02-15 01:00:04
# Generator: MySQL-Front 5.3  (Build 4.234)

/*!40101 SET NAMES utf8 */;

#
# Structure for table "say_admin"
#

DROP TABLE IF EXISTS `say_admin`;
CREATE TABLE `say_admin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '账号，大小写字母数字',
  `password` varchar(62) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '密码',
  `add_time` int(10) NOT NULL DEFAULT '0' COMMENT '添加时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='管理员';

#
# Structure for table "say_comment"
#

DROP TABLE IF EXISTS `say_comment`;
CREATE TABLE `say_comment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) NOT NULL DEFAULT '0' COMMENT '账号ID',
  `topic_id` int(10) NOT NULL DEFAULT '0' COMMENT '话题ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容',
  `status` tinyint(3) DEFAULT '0' COMMENT '状态，1-启用',
  `add_time` int(10) NOT NULL DEFAULT '0' COMMENT '添加时间',
  `add_ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '添加IP',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='评论';

#
# Structure for table "say_topic"
#

DROP TABLE IF EXISTS `say_topic`;
CREATE TABLE `say_topic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) NOT NULL DEFAULT '0' COMMENT '账号ID',
  `title` varchar(120) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '密码',
  `content` text CHARACTER SET utf8mb4 NOT NULL COMMENT '内容',
  `views` int(11) DEFAULT '0' COMMENT '阅读量',
  `status` tinyint(3) DEFAULT '0' COMMENT '状态，1-启用',
  `add_time` int(10) NOT NULL DEFAULT '0' COMMENT '添加时间',
  `add_ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '添加IP',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='话题';

#
# Structure for table "say_user"
#

DROP TABLE IF EXISTS `say_user`;
CREATE TABLE `say_user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '账号，大小写字母数字',
  `cookie` varchar(62) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '密码',
  `sign` varchar(200) CHARACTER SET utf8mb4 DEFAULT '' COMMENT '签名',
  `status` tinyint(1) DEFAULT '1' COMMENT '1-启用，0-禁用',
  `add_time` int(10) NOT NULL DEFAULT '0' COMMENT '添加时间',
  `add_ip` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '添加IP',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='用户';
