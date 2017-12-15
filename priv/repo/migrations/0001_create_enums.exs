defmodule Alastair.Repo.Migrations.CreateEnums do
  use Ecto.Migration

  def change do
    PermissionTypeEnum.create_type
    ApprovalStateEnum.create_type
  end
end
