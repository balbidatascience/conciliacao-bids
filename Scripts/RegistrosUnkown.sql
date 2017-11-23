SET IDENTITY_INSERT dbo.[dimTransacaoAdquirente] on
go
INSERT INTO [dbo].[dimTransacaoAdquirente]
	(IdTransacaoAdquirente, Conciliada)
     VALUES
           (-1, 
		   'Em aberto')
go
SET IDENTITY_INSERT dbo.[dimTransacaoAdquirente] off
go


SET IDENTITY_INSERT dbo.[dimTransacaoIR] on
go
INSERT INTO [dbo].[dimTransacaoIR]
	(IdTransacaoIR, Conciliacao)
     VALUES
           (-1, 
		   'Em aberto')
go
SET IDENTITY_INSERT dbo.[dimTransacaoIR] off
go


SET IDENTITY_INSERT dbo.[dimTempo] on
go
INSERT INTO [dbo].[dimTempo]
	(IdTempo)
     VALUES
           (-1)
go
SET IDENTITY_INSERT dbo.[dimTempo] off
go

SET IDENTITY_INSERT dbo.[dimProduto] on
go
INSERT INTO [dbo].[dimProduto]
	(IdProduto, Tipo, Produto, Bandeira)
     VALUES
           (-1, 
		   'N/A', 'N/A', 'N/A')
go
SET IDENTITY_INSERT dbo.[dimProduto] off
go


SET IDENTITY_INSERT dbo.[dimProduto] on
go
INSERT INTO [dbo].[dimProduto]
	(IdProduto, Tipo, Produto, Bandeira)
     VALUES
           (-1, 
		   'N/A', 'N/A', 'N/A')
go
SET IDENTITY_INSERT dbo.[dimProduto] off
go

SET IDENTITY_INSERT [dbo].[dimDomicilioBancario] on
go
INSERT INTO [dbo].[dimDomicilioBancario]
	(IdConta, Banco, Agencia, Conta)
     VALUES
           (-1, 
		   'N/A', 'N/A', 'N/A')
go
SET IDENTITY_INSERT dbo.[dimDomicilioBancario] off
go

SET IDENTITY_INSERT [dbo].dimLoteVenda on
go
INSERT INTO [dbo].dimLoteVenda
	(IdLoteVenda, Lote, LoteUnico, FiliacaoEstabelecimento, Adquirente, Estabelecimento)
     VALUES
           (-1, 
		   'N/A', 'N/A', 'N/A', 'N/A', 'N/A')
go
SET IDENTITY_INSERT dbo.dimLoteVenda off
go




