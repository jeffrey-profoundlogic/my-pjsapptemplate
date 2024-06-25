/* =============================================================================
  Stored procedure to load the Atrium user/group DB from the User Profiles
    in the OS (only user profiles that DON'T start with 'Q').

  Loads tables ATGROUPSP and ATUSERSP
  Updates table ATUIDSP

  To use on an IBM i....
    Create
      - RUNSQLSTM SRCFILE(?????/?????) SRCMBR(LOADOSATR) COMMIT(*NONE)
      -- OR --
      - Use Run SQL Scripts
    Execute - Make sure both the stored proc AND Atrium DB is in your
      *LIBL.
      - From 5250 session
        - STRSQL
        - CALL LOADOSATR() -- OR -- CALL Load_OSUser_Atrium()
      - From SQL environment
        - CALL LOADOSATR() -- OR -- CALL Load_OSUser_Atrium()

==============================================================================*/

create or replace procedure Load_OSUser_Atrium ()
specific LOADOSATR
set option commit = *none
begin

  declare h_Sequence dec(9);
  declare sv_Sequence dec(9);
  declare h_GroupExists dec(9);
  declare h_GroupNum dec(9);
  declare h_GroupName varchar(128);
  declare h_Aurole varchar(1);
  declare h_Auedit varchar(1);
  declare sqlstate char(5) default '00000';
  declare c_user varchar(10);
  declare c_userclass varchar(10);
  declare c_group varchar(10);
  declare c_usertext varchar(50);
  declare c cursor for
    select authorization_name, group_profile_name,
           coalesce(text_description,authorization_name),
           user_class_name
      from qsys2.user_info
     where substring(authorization_name,1,1) <> 'Q'
     order by authorization_name;

  -- retrieve the next sequence number
  select x.auinext into h_Sequence
    from atuidsp as x
   where x.auifield = 'GRPUSRID';
  set sv_Sequence = h_Sequence;

  -- Loop through all users that don't start with a 'Q'
  open c;
  fetch from c into c_user, c_group, c_usertext, c_userclass;
  while(sqlstate = '00000') do

    -- Figure out the group
    if (c_group = '*SECOFR') then
      set h_GroupName  = 'Administrators';
    elseif (c_group = '*PGMR') then
      set h_GroupName = 'Development';
    else
      set h_GroupName = 'Users';
    end if;

    -- translate the 'user class' to role and edit
    if (c_userclass = '*USER') then
      set h_Aurole = '0';
      set h_Auedit = '0';
    else
      set h_Aurole = '2';
      set h_Auedit = '1';
    end if;

    -- get the group # or NULL
    set h_GroupExists =
        (select aggroup from atgroupsp where agname = h_GroupName);
    -- get the group number....
    --   create the passed in group (if it doesn't exist)
    if h_GroupExists >= 0 then
      set h_GroupNum = h_GroupExists;
    else
      --insert into atgroupsp (aggroup, agparent, agname)
      --               values (h_Sequence, 0, h_GroupName);
      set h_GroupNum = h_Sequence;
      set h_Sequence = h_Sequence + 1;
    end if;

    -- create the user
    --if not exists
    --   (select 1 from atusersp where auprof = c_user) then
    --  insert into atusersp (auuser, augroup, aurole,
    --                        auedit, auname, auprof)
    --                values (h_Sequence, h_GroupNum, h_Aurole,
    --                       h_Auedit, c_usertext, c_user);
      set h_Sequence = h_Sequence + 1;
    --end if;

    fetch from c into c_user, c_group, c_usertext, c_userclass;
  end while;

  close c;

  -- save the next sequence number
  if sv_Sequence <> h_Sequence then
    --update atuidsp as x
    --   set x.auinext = h_Sequence
    -- where x.auifield = 'GRPUSRID';
  end if;

  return 1;

end;