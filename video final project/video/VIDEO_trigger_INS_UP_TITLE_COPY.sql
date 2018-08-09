create or replace trigger ins_up_title_copy
after update of checkin_date or insert on rental
for each row

begin
  if inserting then 
  -- up date status of video being checked out to 'CHECKED OUT' 
    update title_copy
    set STATUS='CHECKED OUT'
    where COPY_ID=:new.copy_id;
  elsif updating then
  -- update title_copy status to 'IN STORE'
  -- when the video is checked in
    update title_copy
    set STATUS='IN STORE'
    where COPY_ID=:old.copy_id;
  end if; 
end;