defmodule Alastair.Repo.Migrations.CreateEnums do
  use Ecto.Migration

  def change do
    PermissionTypeEnum.create_type
  end
end
