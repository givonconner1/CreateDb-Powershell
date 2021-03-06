--REPLACE C: with F: when transferring to Azure

CREATE DATABASE [$(dbName)]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'$(dbName)', FILENAME = N'C:\Data\$(dbName).mdf' , SIZE = 93184KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'$(dbName)_log', FILENAME = N'C:\Log\$(dbName)_log.ldf' , SIZE = 47616KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

ALTER DATABASE [$(dbName)] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [$(dbName)].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [$(dbName)] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [$(dbName)] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [$(dbName)] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [$(dbName)] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [$(dbName)] SET ARITHABORT OFF 
GO

ALTER DATABASE [$(dbName)] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [$(dbName)] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [$(dbName)] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [$(dbName)] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [$(dbName)] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [$(dbName)] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [$(dbName)] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [$(dbName)] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [$(dbName)] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [$(dbName)] SET  DISABLE_BROKER 
GO

ALTER DATABASE [$(dbName)] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [$(dbName)] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [$(dbName)] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [$(dbName)] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [$(dbName)] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [$(dbName)] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [$(dbName)] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [$(dbName)] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [$(dbName)] SET  MULTI_USER 
GO

ALTER DATABASE [$(dbName)] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [$(dbName)] SET DB_CHAINING OFF 
GO

ALTER DATABASE [$(dbName)] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [$(dbName)] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

ALTER DATABASE [$(dbName)] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [$(dbName)] SET  READ_WRITE 
GO

USE [master]
GO

CREATE LOGIN [$(user)] WITH PASSWORD=N'$(sqlPassword)', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [master]
GO

GRANT CONNECT SQL TO [$(user)]
GO
	
use $(dbName)
GO
CREATE USER [$(user)] FOR LOGIN [$(user)]
GO
USE $(dbName)
GO
ALTER ROLE [db_owner] ADD MEMBER [$(user)]
GO
